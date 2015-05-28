router = require('express').Router()
async = require 'async'
{request, sms, cryptx, asynchError} = require '@gp-technical/sapify-api'
sso_domain = process.env.MICRO_SSO_DOMAIN

router.get '/', (req, res, next) ->
	options=
		method:'GET'
		uri: "#{sso_domain}/user"
	request(options, req.headers).pipe(res)

router.get '/:id', (req, res, next) ->
	options=
		method:'GET'
		uri: "#{sso_domain}/user/#{req.params.id}"
	request(options, req.headers).pipe(res)

router.get '/authenticated/:email/:secret', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/user?email=#{encodeURIComponent req.params.email}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, JSON.parse(data)[0]
		(user, cb)->
			cryptx.authenticate req.params.secret, user.hash, (err, authenticated)->
				return cb 401 unless authenticated?
				cb null, user
		(user, cb)->
			sms.sendVerificationCode user, (err, verification)->
				verification.key = req.params.email
				cb null, verification
		(verification, cb)->
			options=
				method:'POST'
				uri:"#{sso_domain}/verification"
				form:verification
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, vid:JSON.parse(data).vid
	], (err, vid)->
		return res.sendStatus err if err?
		res.json vid

router.get '/verified/:vid/:mac', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri:"#{sso_domain}/verification?vid=#{encodeURIComponent req.params.vid}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				verification = JSON.parse(data)[0]
				return cb 401 unless verification.mac is req.params.mac
				cb null, verification
		(verification, cb)->
			options=
				method:'GET'
				uri:"#{sso_domain}/user?email=#{encodeURIComponent verification.key}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, JSON.parse(data)[0]
		(user, cb)->
			token = key:user.email, value: cryptx.secret 32
			options=
				method:'POST'
				uri:"#{sso_domain}/token"
				form:token
			request options, req.headers, (err, resp)->
				return if asynchError.handle cb, options, err, resp
				cb null, token
	], (err, token)->
		return res.sendStatus err if err?
		res.json token

module.exports = router