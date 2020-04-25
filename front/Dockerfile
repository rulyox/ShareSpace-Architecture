FROM node:12

WORKDIR /app

COPY ./app .

RUN npm install

ENTRYPOINT ["npm", "run", "build"]
