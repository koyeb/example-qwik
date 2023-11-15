# Build stage
FROM node:lts-alpine AS builder

USER node
WORKDIR /home/node

COPY package*.json .
RUN npm ci

COPY --chown=node:node . .
RUN npm run build


# Final run stage
FROM node:lts-alpine AS runner

ENV NODE_ENV production
USER node
WORKDIR /home/node

COPY --from=builder --chown=node:node /home/node/package*.json .
COPY --from=builder --chown=node:node /home/node/node_modules ./node_modules
COPY --from=builder --chown=node:node /home/node/dist ./dist
COPY --from=builder --chown=node:node /home/node/server ./server

ARG PORT
EXPOSE ${PORT:-3000}

CMD ["node", "server/entry.express"]
