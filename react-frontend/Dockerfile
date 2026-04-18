# silence the platform warning
ARG TARGETPLATFORM=linux/amd64

# Stage 1: Build React App with Vite
# Bumped to node:20 to support Vite 6+
FROM --platform=${TARGETPLATFORM} node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with NGINX
FROM --platform=${TARGETPLATFORM} nginx:alpine
# Vite build outputs to the 'dist' folder
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
