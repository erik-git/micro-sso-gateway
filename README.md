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

### The .env file
Environment variables are supplied via a .env file (see [dotenv](https://github.com/bkeepers/dotenv)). The micro-sso-gateway api relies on the micro-sso-domain api which in  turn relies ona mongoDB. To make your setup easier the micro-sso-domain api has been mocked out using an Apiary blueprint document - see [micro-sso-domain mock](http://docs.microssodomain.apiary.io/#).

The example .env file below points the micro-sso-gateway api to the Apiary blueprint. This allows you to run this micro-sso-gateway api in isolation.

```
NODE_ENV='development'
NODE_PORT=5001
IS_APIARY=true
MICRO_SSO_DOMAIN='http://private-331cdc-microssodomain.apiary-mock.com'

```

### Who do I talk to? ###

* Jonny Anderson : janderson@goodpractice.com