FROM node:20-alpine AS base
WORKDIR /app

COPY package.json package-lock.json ./

FROM base AS prod-deps
RUN npm install --omit=dev

FROM base AS build-deps
RUN npm install

FROM build-deps AS build
COPY . .
RUN npm run build

FROM base AS runtime
COPY --from=prod-deps /app/node_modules ./node_modules # Copy dependencies
COPY --from=build /app/dist ./dist # Copy the built output

# Bind to all interfaces
ENV HOST=0.0.0.0
# Port to listen on
ENV PORT=4321
# Just convention, not required
EXPOSE 4321

CMD node ./dist/server/entry.mjs # Start the app