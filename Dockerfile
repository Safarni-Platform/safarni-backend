# ===== Stage 1: Build =====
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy dependency files first to leverage Docker layer caching (FAST Builder)
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

# Copy the application source code
COPY . .

# Build the TypeScript application
RUN npm run build

# ===== Stage 2: Production =====
FROM node:20-alpine

# Set the working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy the compiled application from the build stage
COPY --from=builder /app/dist ./dist

# Copy static assets if the project contains a public folder
# COPY --from=builder /app/public ./public


# Switch to the built-in non-root user
USER node

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["node", "dist/server.js"]