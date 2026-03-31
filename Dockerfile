# Static Astro: build with Node, serve with nginx (Fly.io expects a long-lived HTTP listener on internal_port).
# syntax=docker/dockerfile:1

FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:1.27-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.fly.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# Must match [[http_service]] internal_port in fly.toml
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
