# micro-sso-gateway
A REST gateway api that fronts the micro-sso-domain api.

See also:
- [micro-sso-domain](https://github.com/biofractal/micro-sso-domain)

### What is this repository for? ###

* Collates and processes [micro-sso-domain](https://github.com/biofractal/micro-sso-domain) concrete resources.
* Provides a central two factor sign-in ui for users and two-factor api end-points for machine authentication

### How do I get started? ###

* fork this repo
* add a .env file (see below)
* `npm -g shelljs`
* `npm install`
* `npm run build`
* In a browser navigate to `http://localhost:5001/user/authenticated/form` (the port is determined by the .env file - see below)

### Mocking out the dependencies
The micro-sso-gateway api depends on the [micro-sso-domain](https://github.com/biofractal/micro-sso-domain) api which in  turn depends on [mongoDB](https://www.mongodb.org/).

To make your setup easier the micro-sso-domain api has been mocked out using an Apiary blueprint document. You can view and test this mock api at [micro-sso-domain mock](http://docs.microssodomain.apiary.io/#).

Mocking out the dependencies in this way allows you to run the micro-sso-gateway api in isolation.

### The .env file
Environment variables are supplied via a `.env` file (see [dotenv](https://github.com/bkeepers/dotenv)). The real `.env` file is not included in this repo (by design) and therefore you will need to create one and place it in the root of the project.

The example `.env` file below points the micro-sso-gateway api to the Apiary blueprint. For convenience this safe sample `.env` file has been included in the repo and is called `.env.mock`. You should rename this file to `.env`.

```
NODE_ENV='development'
NODE_PORT=5001
IS_APIARY=true
MICRO_SSO_DOMAIN='http://private-331cdc-microssodomain.apiary-mock.com'

```

### Who do I talk to? ###

* Jonny Anderson : janderson@goodpractice.com