router = require('express').Router()
async = require 'async'
{request, sms, cryptx, asynchError, cookies} = require '@gp-technical/sapify-api'
sso_domain = process.env.MICRO_SSO_DOMAIN

router.get '/authenticated/form', (req, res)->
	res.render 'authenticate', title:'authenticate'

router.post '/authenticated', (req, res, next) ->
	{token} = req.cookies
	{email, secret} = req.body
	headers = {'token':token}
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/user?email=#{encodeURIComponent email}"
			request options, headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, JSON.parse(data)[0]
		(user, cb)->
			cryptx.authenticate secret, user.hash, (err, authenticated)->
				return cb 401 unless authenticated?
				cb null, user
		(user, cb)->
			sms.sendVerificationCode user, (err, verification)->
				verification.key = email
				cb null, verification
		(verification, cb)->
			options=
				method:'POST'
				uri:"#{sso_domain}/verification"
				form:verification
			request options, headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, JSON.parse(data)
	], (err, verification)->
		return res.sendStatus err if err?
		res.render 'verify', title:'verify', vid:verification.vid

router.post '/verified', (req, res, next) ->
	{state, token, returnUrl} = req.cookies
	cookies.clearAll req, res
	{mac, vid} = req.body
	headers = {'token':token}
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri:"#{sso_domain}/verification?vid=#{encodeURIComponent vid}"
			request options, headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				verification = JSON.parse(data)[0]
				return cb 401 unless verification.mac is mac
				cb null, verification
		(verification, cb)->
			options=
				method:'GET'
				uri:"#{sso_domain}/user?email=#{encodeURIComponent verification.key}"
			request options, headers, (err, resp, data)->
				return if asynchError.handle cb, options, err, resp
				return if asynchError.isMissing cb, options, data
				cb null, JSON.parse(data)[0]
		(user, cb)->
			usertoken = key:user.email, value: cryptx.secret 32
			options=
				method:'POST'
				uri:"#{sso_domain}/token"
				form:usertoken
			request options, headers, (err, resp)->
				return if asynchError.handle cb, options, err, resp
				cb null, usertoken
	], (err, usertoken)->
		return res.sendStatus err if err?
		res.redirect "#{returnUrl}/#{state}/#{usertoken.value}"

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

module.exports = router