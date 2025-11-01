# -------------------- Stage 1: Build React App --------------------
FROM node:18-alpine AS build

WORKDIR /app

# Pass environment variables at build time
ARG REACT_APP_API_URL
ARG REACT_APP_API_URL_DATA

# Copy and install dependencies
COPY package*.json ./
RUN npm install

# Copy rest of app
COPY . .

# Make sure environment variables are available for the build
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_API_URL_DATA=$REACT_APP_API_URL_DATA

# Build React app
RUN npm run build

# -------------------- Stage 2: Serve with Nginx --------------------
FROM nginx:alpine

# Copy built React app
COPY --from=build /app/build /usr/share/nginx/html

# Optional custom Nginx config for React Router
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
