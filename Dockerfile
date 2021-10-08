# syntax=docker/dockerfile:1

FROM node:14

WORKDIR /usr

COPY package.json ./
COPY tsconfig.json ./
COPY src ./src

RUN ls -a
RUN npm install
RUN npm run build


FROM node:14

WORKDIR /usr

COPY package.json ./

RUN npm install --only=production

COPY --from=0 /usr/dist .

ENV NODE_ENV=production

EXPOSE 3000

CMD [ "node", "main.js" ]