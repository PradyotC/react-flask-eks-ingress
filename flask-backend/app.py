from flask import Flask, jsonify, render_template_string
import os
import pymysql

app = Flask(__name__)

# Fetch DB configs from K8s Secrets/ConfigMaps injected as environment variables
DB_HOST = os.environ.get('DB_HOST', 'mysql-internal-svc')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASS = os.environ.get('DB_PASSWORD', 'supersecret')
DB_NAME = os.environ.get('DB_NAME', 'capstone_db')

def get_db_connection():
    try:
        return pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_NAME)
    except Exception as e:
        return None

@app.route('/api/v1/health')
def health_check():
    conn = get_db_connection()
    db_status = "connected" if conn else "disconnected"
    if conn: conn.close()

    return jsonify({
        "service": "flask-backend",
        "status": "operational",
        "dependencies": {"mysql_database": {"status": db_status}}
    })

@app.route('/dashboard')
def dashboard():
    # In a real app, you would fetch real data here.
    conn = get_db_connection()
    db_status = "Healthy" if conn else "Failing"
    if conn: conn.close()

    html_template = """
    <h1>Main Dashboard (Flask SSR)</h1>
    <p>Database Connection Status: <b>{{ status }}</b></p>
    <hr>
    <p><i>Server-side rendered via Jinja</i></p>
    """
    return render_template_string(html_template, status=db_status)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
