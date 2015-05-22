router = require('express').Router()
async = require 'async'
{request, cryptx, isError} = require '@gp-technical/sapify-api'
sso_domain = process.env.MICRO_SSO_DOMAIN

router.get '/authenticated/:key', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/api?key=#{encodeURIComponent req.params.key}"
			request options, req.headers, (err, response, data)->
				return if isError.get cb, err, response, data
				cb null, JSON.parse(data)[0]
		(api, cb)->
			verification =
				key : req.params.key
				vid : cryptx.uuid()
				mac : cryptx.uuid()
			options=
				method:'POST'
				uri: "#{sso_domain}/verification"
				form:verification
			request options, req.headers, (err, response, data)->
				return if isError.err cb, err
				cb null, api, verification
		(api, verification, cb)->
			encrypted = cryptx.encrypt verification.mac, api.secret
			options=
				method:'GET'
				uri: "#{api.url}/sso/callback/#{encodeURIComponent encrypted}/#{encodeURIComponent verification.vid}"
			request options, req.headers, (err, response, data)->
				return if isError.err cb, err
				cb null
	], (err)->
		return res.sendStatus err if err?
		res.sendStatus 200

router.get '/verified/:vid/:decrypted', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/verification?vid=#{encodeURIComponent req.params.vid}"
			request options, req.headers, (err, response, data)->
				return if isError.get cb, err, response, data
				verification = JSON.parse(data)[0]
				return cb 401 unless verification.mac is req.params.decrypted
				cb null, verification
		(verification, cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/api?key=#{encodeURIComponent verification.key}"
			request options, req.headers, (err, response, data)->
				return if isError.get cb, err, response, data
				cb null, JSON.parse(data)[0]
		(api, cb)->
			token = key:api.key, value: cryptx.uuid()
			options=
				method:'POST'
				uri: "#{sso_domain}/token"
				form:token
			request options, req.headers, (err, response, data)->
				return if isError.post cb, err, response
				cb null, token
	], (err, token)->
		return res.sendStatus err if err?
		res.json token

module.exports = router