ARG NODE_VERSION
ARG PNPM_VERSION

# Build stage
FROM node:${NODE_VERSION}-slim AS builder

ARG PNPM_VERSION

WORKDIR /usr/src/app

# Copy metadata + lockfile first for layer caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .pnpmfile.cjs ./

RUN corepack enable \
    && corepack prepare pnpm@${PNPM_VERSION} --activate \
    && pnpm install --prod --frozen-lockfile --ignore-scripts

# Production stage
FROM node:${NODE_VERSION}-slim AS production

WORKDIR /usr/src/app

# Copy installed node_modules from builder (root-owned, read-only to the app)
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application files (root-owned, read-only to the app)
COPY download.js app.js entrypoint.sh ./

# Only dbs/ must be writable; the image's built-in "node" user is uid/gid 1000
RUN mkdir -p dbs && chmod +x entrypoint.sh && chown node:node dbs

# Run as non-root
USER node

EXPOSE 3000

CMD ["./entrypoint.sh"]
