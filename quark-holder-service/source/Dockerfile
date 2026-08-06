FROM node:20-bookworm-slim AS builder
WORKDIR /build

COPY packages/identity-core/package.json packages/identity-core/package-lock.json* /build/packages/identity-core/
COPY packages/identity-core/tsconfig.json /build/packages/identity-core/
COPY packages/identity-core/src /build/packages/identity-core/src
WORKDIR /build/packages/identity-core
RUN npm install \
  && test -f node_modules/@openwallet-foundation/askar-nodejs/native/libaries_askar.so \
  && npm run build

WORKDIR /build/quark-holder-service/source
COPY quark-holder-service/source/package*.json ./
COPY quark-holder-service/source/tsconfig.json ./
COPY quark-holder-service/source/src ./src
RUN npm ci && npm run build

FROM node:20-bookworm-slim AS runner
WORKDIR /build/quark-holder-service/source
COPY --from=builder /build/packages/identity-core /build/packages/identity-core
COPY quark-holder-service/source/package*.json ./
RUN npm ci --omit=dev \
  && rm -rf node_modules/@openwallet-foundation/askar-nodejs \
            node_modules/@openwallet-foundation/askar-shared \
  || true
COPY --from=builder /build/quark-holder-service/source/dist ./dist
RUN test -f /build/packages/identity-core/node_modules/@openwallet-foundation/askar-nodejs/native/libaries_askar.so
EXPOSE 9005
CMD ["node", "dist/main.js"]
