
router = require('express').Router()
async = require 'async'
{request, cryptx, isError, asynchError} = require '@gp-technical/sapify-api'
sso_domain = process.env.MICRO_SSO_DOMAIN

router.get '/authenticated/:key', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/api?key=#{encodeURIComponent req.params.key}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, err, resp
				return if asynchError.isMissing cb, data
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
			console.log 'verification', verification
			request options, req.headers, (err, resp, data)->
				console.log 'posting'
				return if asynchError.handle cb, err, resp
				console.log 'no error'
				cb null, api, verification
		(api, verification, cb)->
			encrypted = cryptx.encrypt verification.mac, api.secret
			options=
				method:'GET'
				uri: "#{api.url}/sso/callback/#{encodeURIComponent encrypted}/#{encodeURIComponent verification.vid}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, err, resp
				cb null
	], (errCode)->
		return res.sendStatus errCode if errCode?
		res.sendStatus 200

router.get '/verified/:vid/:decrypted', (req, res, next) ->
	async.waterfall [
		(cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/verification?vid=#{encodeURIComponent req.params.vid}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, err, resp
				return if asynchError.isMissing cb, data
				verification = JSON.parse(data)[0]
				return cb 401 unless verification.mac is req.params.decrypted
				cb null, verification
		(verification, cb)->
			options=
				method:'GET'
				uri: "#{sso_domain}/api?key=#{encodeURIComponent verification.key}"
			request options, req.headers, (err, resp, data)->
				return if asynchError.handle cb, err, resp
				return if asynchError.isMissing cb, data
				cb null, JSON.parse(data)[0]
		(api, cb)->
			token = key:api.key, value: cryptx.secret 32
			options=
				method:'POST'
				uri: "#{sso_domain}/token"
				form:token
			request options, req.headers, (err, resp, data)->
				return if resp.errorHandled
				cb null, token
	], (errCode, token)->
		return res.sendStatus errCode if errCode?
		res.json token

module.exports = router