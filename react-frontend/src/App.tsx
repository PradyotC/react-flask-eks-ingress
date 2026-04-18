import { useState } from "react";
import "./App.css";

function App() {
  const [healthStatus, setHealthStatus] = useState<string | null>(null);

  const checkBackendHealth = async () => {
    try {
      // Notice we just call the relative path!
      // The AWS ALB Ingress will intelligently route this to the Flask Pod.
      const response = await fetch("/api/v1/health");
      const data = await response.json();
      setHealthStatus(JSON.stringify(data, null, 2));
    } catch (error) {
      setHealthStatus("Error connecting to backend API.");
    }
  };

  return (
    <div className="App">
      <h1>🚀 Capstone Infrastructure</h1>
      <h2>React Frontend → AWS ALB → Flask Backend → MySQL</h2>

      <div className="card">
        <button onClick={checkBackendHealth}>Ping Backend API</button>

        {healthStatus && (
          <div
            style={{
              marginTop: "20px",
              textAlign: "left",
              background: "#222",
              padding: "15px",
              borderRadius: "8px",
            }}
          >
            <pre style={{ color: "#00ff00", margin: 0 }}>{healthStatus}</pre>
          </div>
        )}
      </div>
      <p className="read-the-docs">
        Routing handled by AWS Application Load Balancer
      </p>
    </div>
  );
}

export default App;
