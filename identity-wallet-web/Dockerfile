# Static production build for the browser wallet.
FROM node:22-alpine AS build
WORKDIR /app
COPY identity-wallet-web/package.json ./package.json
RUN npm install --no-audit --no-fund
COPY identity-wallet-web/ ./
RUN npm run build

FROM nginx:alpine
COPY identity-wallet-web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
