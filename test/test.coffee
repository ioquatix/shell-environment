vows = require('vows')
assert = require 'assert'

ShellEnvironment = require '../lib/index.coffee'

vows
	.describe('Loading shell environment variables')
	.addBatch
		'when loading from login shell':
			topic: -> 
				ShellEnvironment.loginEnvironment(this.callback)
				return undefined # for async call
			'results in a valid path': (error, result) ->
				assert(result.PATH)
			'results in a valid home': (error, result) ->
				assert(result.HOME)
	.export(module)
