FROM node:20-bookworm-slim AS builder
WORKDIR /build

# Copiar fuentes sin node_modules del host (evita aries_askar.dll de Windows).
COPY packages/identity-core/package.json packages/identity-core/package-lock.json* /build/packages/identity-core/
COPY packages/identity-core/tsconfig.json /build/packages/identity-core/
COPY packages/identity-core/src /build/packages/identity-core/src
WORKDIR /build/packages/identity-core
RUN npm install \
  && test -f node_modules/@openwallet-foundation/askar-nodejs/native/libaries_askar.so \
  && npm run build

WORKDIR /build/quark-issuer-service/source
COPY quark-issuer-service/source/package*.json ./
COPY quark-issuer-service/source/tsconfig.json ./
COPY quark-issuer-service/source/src ./src
RUN npm ci && npm run build

FROM node:20-bookworm-slim AS runner
WORKDIR /build/quark-issuer-service/source
COPY --from=builder /build/packages/identity-core /build/packages/identity-core
COPY quark-issuer-service/source/package*.json ./
RUN npm ci --omit=dev \
  && rm -rf node_modules/@openwallet-foundation/askar-nodejs \
            node_modules/@openwallet-foundation/askar-shared \
  || true
COPY --from=builder /build/quark-issuer-service/source/dist ./dist
# Verificación en runtime image: nativo Linux presente en identity-core.
RUN test -f /build/packages/identity-core/node_modules/@openwallet-foundation/askar-nodejs/native/libaries_askar.so
EXPOSE 9001
CMD ["node", "dist/main.js"]
