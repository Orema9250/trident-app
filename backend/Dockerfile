FROM  node:22-slim AS build-stage

WORKDIR /usr/src/app

COPY backend/package.json backend/package-lock.json ./

RUN npm ci --omit=dev

FROM  node:22-alpine AS runtime-stage

WORKDIR /usr/src/app

RUN apk add --no-cache postgresql-client

COPY --from=build-stage /usr/src/app/node_modules ./node_modules

COPY backend/package.json backend/package-lock.json ./ 

COPY backend/src ./src

COPY database ./database

EXPOSE 3000

CMD ["node", "src/server.js"]