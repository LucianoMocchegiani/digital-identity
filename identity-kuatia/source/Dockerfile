# Build desde la raíz del monorepo:
#   docker build -f identity-kuatia/source/Dockerfile .
#
# BILLING_URL / ISSUER_URL / VERIFIER_URL se bakean en los rewrites de Next.

FROM node:20-bookworm-slim AS deps
WORKDIR /app
COPY identity-kuatia/source/package*.json ./
RUN npm ci

FROM node:20-bookworm-slim AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY identity-kuatia/source/ ./
ARG BILLING_URL=http://identity-billing-service:9000
ARG ISSUER_URL=http://identity-issuer-service:9001
ARG VERIFIER_URL=http://identity-verifier-service:9002
ARG NEXT_PUBLIC_SITE_URL=https://kuatia.xyz
ARG NEXT_PUBLIC_CONTACT_EMAIL=hola@kuatia.xyz
ENV BILLING_URL=$BILLING_URL
ENV ISSUER_URL=$ISSUER_URL
ENV VERIFIER_URL=$VERIFIER_URL
ENV NEXT_PUBLIC_SITE_URL=$NEXT_PUBLIC_SITE_URL
ENV NEXT_PUBLIC_CONTACT_EMAIL=$NEXT_PUBLIC_CONTACT_EMAIL
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:20-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

RUN addgroup --system --gid 1001 nodejs \
  && adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
