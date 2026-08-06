FROM node:20-bookworm-slim AS builder
WORKDIR /build/identity-billing-service/source
COPY identity-billing-service/source/package*.json ./
COPY identity-billing-service/source/tsconfig.json ./
COPY identity-billing-service/source/src ./src
RUN npm ci && npm run build

FROM node:20-bookworm-slim AS runner
WORKDIR /build/identity-billing-service/source
COPY identity-billing-service/source/package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /build/identity-billing-service/source/dist ./dist
EXPOSE 9000
CMD ["node", "dist/main.js"]
