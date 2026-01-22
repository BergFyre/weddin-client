# syntax=docker/dockerfile:1

FROM node:18-alpine AS build
WORKDIR /app

ARG API
ARG mediaHost
ARG adminPanel
ARG VUE_APP_WS_URL

ENV API=$API
ENV mediaHost=$mediaHost
ENV adminPanel=$adminPanel
ENV VUE_APP_WS_URL=$VUE_APP_WS_URL

COPY package*.json ./
RUN npm install

COPY . .
# Quasar/Vue build -> dist/
RUN npm run build

FROM nginx:1.25-alpine AS runtime
# SPA routing fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Quasar SPA output:
COPY --from=build /app/dist/spa /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD wget -qO- http://localhost:8080/ >/dev/null 2>&1 || exit 1
