require('dotenv').load()
express = require 'express'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
winston = require 'winston'
env = process.env

#app
app = express()
app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()
app.use cookieParser()
app.set('views', "#{__dirname}/views")
app.set('view engine', 'jade')

app.use("/public", express.static(__dirname + '/public'));

#app routes
app.get '/', (req, res)->
	res.send 'gateway api is up and running'

app.use '/user', require './routes/user'
app.use '/api', require './routes/api'

#app start
app.listen(env.NODE_PORT, ->
	winston.info "micro-sso-gateway api listening on port #{env.NODE_PORT}"
)