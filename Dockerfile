# Build stage
FROM node:22.17.1-slim AS builder

# Set the working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package.json ./
RUN npm install --only=production
RUN npm cache clean --force

# Production stage
FROM node:22.17.1-slim AS production

# Set the working directory
WORKDIR /usr/src/app

# Copy node_modules from builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application files
COPY download.js ./
COPY app.js ./
COPY entrypoint.sh ./

# Make entrypoint executable
RUN mkdir -p dbs && \
    chmod +x entrypoint.sh

# Web application port
EXPOSE 3000

# Download db and run the app
CMD ["./entrypoint.sh"]
