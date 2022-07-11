FROM node:10-alpine

COPY package.json  /app/

WORKDIR /app

RUN npm install

COPY . /app

CMD ["npm", "start"]