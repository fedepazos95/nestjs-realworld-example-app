# ![Node/Express/Mongoose Example App](project-logo.png)

[![Build Status](https://travis-ci.org/anishkny/node-express-realworld-example-app.svg?branch=master)](https://travis-ci.org/anishkny/node-express-realworld-example-app)

> ### Modified version of NestJS codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld-example-apps) API spec.


----------

# Getting started


## Comments and thoughs
- Instead of just changing the database configuration in `ormconfig.json` I decided to remove it and configure it with environment variables in order to have the possibility to dynamically configure several types of databases, also made this specially thinking in an ECS deployment with the variables stored in AWS Parameter Store.
- I added two Dockerfile, one for production and the other for local development using docker-compose.
- I used Terraform to create the base infrastructure: all networking configuration, ECR repository, the Task Definition, the ECS Cluster and the ECS Service.
- I used a Github workflow to build and deploy the docker container to AWS. There is a manual step before launching a new release, it's neccesary to get the Task Definition from AWS in JSON format and add it to the repo, this is a point where surelly can be improved, but I didn't want to spend so much time on it.
- The service is built and deployed through Releases, assuming that you already have a Database running inside the VPC and you already added the configuration values to AWS Parameter Store.
- I've choosen AWS to deploy it because it's the cloud provider where I have most experience and it's also the one that I decided to specialize in first.

## Installation

Clone the repository

    git clone https://github.com/fedepazos95/nestjs-realworld-example-app.git

Switch to the repo folder

    cd nestjs-realworld-example-app
    
Install dependencies
    
    npm install

Create an .env file in the root folder and set up the required environment variables

    touch .env

- `PORT` - Port to start application. Optional
- `SECRET_KEY` - JsonWebToken secret key
- `TYPEORM_CONNECTION` - Type of the database. Eg: Postgres - Mysql - etc. 
- `TYPEORM_HOST` - Host of the database
- `TYPEORM_USERNAME` - Username to connect to the database
- `TYPEORM_PASSWORD` - Password of the user
- `TYPEORM_DATABASE` - Database name
- `TYPEORM_PORT` - Database port
- `TYPEORM_SYNCHRONIZE` - If true, automatically loaded models will be synchronized (default: true. This shouldn't be used in production)
- `TYPEORM_LOGGING` - Enable logging (default: true)
- `TYPEORM_ENTITIES` - Paths to entities (default: `"./**/*.entity.js,./**/*.entity.ts"`)

----------

## How to Deploy

- Run the Terraform workflow pushing new changes to the repo or triggering manually in Github.
- Download from AWS ECS the Task Definition JSON file and update it in `.aws/task_definition.json`
- Push the Task Definition with `[ci skip]` in the commit message to avoid triggering the workflow.
- Create a new Release and Tag in Github in order to trigger the AWS Deploy workflow.

The service will be deployed inside the VPC with no public access, in order to test it we need to update the Security Group of the VPC to allow ingress traffic on port 3000 for our IP or all IPs.

----------

## Database

The codebase contains examples of two different database abstractions, namely [TypeORM](http://typeorm.io/) and [Prisma](https://www.prisma.io/). 
    
The branch `master` implements TypeORM.

The branch `prisma` implements Prisma with a mySQL database.

----------

##### TypeORM

----------

Create a new database with the name `nestjsrealworld`\
(or the name you specified in the .env file)

Be sure to complete all the required envs listed in the Installation section
    
On application start, tables for all entities will be created.

----------

##### Prisma

----------

To run the example with Prisma checkout branch `prisma`, remove the node_modules and run `npm install`

Create a new mysql database with the name `nestjsrealworld-prisma` (or the name you specified in `prisma/.env`)

Copy prisma config example file for database settings

    cp prisma/.env.example prisma/.env

Set mysql database settings in prisma/.env

    DATABASE_URL="mysql://USER:PASSWORD@HOST:PORT/DATABASE"

To create all tables in the new database make the database migration from the prisma schema defined in prisma/schema.prisma

    npx prisma migrate save --experimental
    npx prisma migrate up --experimental

Now generate the prisma client from the migrated database with the following command

    npx prisma generate

The database tables are now set up and the prisma client is generated. For more information see the docs:

- https://www.prisma.io/docs/getting-started/setup-prisma/add-to-existing-project-typescript-mysql


----------

## Dockerized development

The codebase contains a `docker-compose.yml` and `Dockerfile.dev` to start both server and database locally, it's configured with a Postgres container

    docker-compose up

> When running with docker-compose, the value of TYPEORM_HOST must be the name specified in `docker-compose.yml` for the database container, in this case 'postgres'

----------

## Seed script

The codebase contains a NodeJS script to insert rows to the database. Only supports the Tag entity, but can be extended to more entities.

How it works? Indicating the name of the entity and the amount to insert through attributes in the execution

    node scripts/seed-db.js --tags 10

----------

## Benchmark script

Also contains a Bash script to run benchmark test on the API.

How it works? Indicating the number of connections, number of requests and the endpoints to test

    # Executing 100 requests on each endpoint with 10 connections
    bash scripts/benchmark.sh 10 100 http://localhost:3000/api/articles http://localhost:3000/api/tags

----------
## NPM scripts

- `npm start` - Start application
- `npm run start:watch` - Start application in watch mode
- `npm run test` - run Jest test runner 
- `npm run build` - Build application

----------

## API Specification

This application adheres to the api specifications set by the [Thinkster](https://github.com/gothinkster) team. This helps mix and match any backend with any other frontend without conflicts.

> [Full API Spec](https://github.com/gothinkster/realworld/tree/master/api)

More information regarding the project can be found here https://github.com/gothinkster/realworld

----------

## Start application

- `npm start`
- Test api with `http://localhost:3000/api/articles` in your favourite browser

----------

# Authentication
 
This applications uses JSON Web Token (JWT) to handle authentication. The token is passed with each request using the `Authorization` header with `Token` scheme. The JWT authentication middleware handles the validation and authentication of the token. Please check the following sources to learn more about JWT.

----------
 
# Swagger API docs

This example repo uses the NestJS swagger module for API documentation. [NestJS Swagger](https://github.com/nestjs/swagger) - [www.swagger.io](https://swagger.io/)        
