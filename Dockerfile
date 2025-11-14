# Multi-stage build for Slidev presentation
# 1) Build stage: install dependencies and run the Slidev build
# 2) Production stage: serve the generated static files with nginx

FROM node:20-alpine AS builder
WORKDIR /app

# Install deps. Copy package.json only first for better caching
COPY package.json package-lock.json* ./

# Use npm install (no lockfile means npm will generate one in the image)
RUN npm install --no-audit --no-fund

# Copy rest of the project
COPY . .

# Build the static site (Slidev outputs to `dist` by default)
RUN npm run build


FROM nginx:stable-alpine AS production
# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy built assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 and run nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
