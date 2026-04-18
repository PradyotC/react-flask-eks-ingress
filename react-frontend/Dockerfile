# Stage 1: Build React App with Vite
FROM --platform=linux/amd64 node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# Vite build outputs to the 'dist' folder
RUN npm run build

# Stage 2: Serve with NGINX
FROM --platform=linux/amd64 nginx:alpine
# Note the change from /app/build to /app/dist
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
