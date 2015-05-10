vows = require('vows')
assert = require 'assert'

ShellEnvironment = require '../lib/index.coffee'

vows
	.describe('Loading shell environment variables')
	.addBatch
		'when loading from login shell':
			topic: -> 
				ShellEnvironment.loginEnvironment(this.callback)
			'results in a valid path': (error, result) ->
				assert(result.PATH)
			'results in a valid home': (error, result) ->
				assert(result.HOME)
	.addBatch
		'when loading with invalid command':
			topic: ->
				shellEnvironment = new ShellEnvironment(command: 'borked')
				shellEnvironment.getEnvironment(this.callback)
			'results in error': (error, result) ->
				assert(error)
	.addBatch
		'with cache period':
			topic: ->
				shellEnvironment = new ShellEnvironment(cachePeriod: 1)
				shellEnvironment.getEnvironment (this.callback.bind(null, shellEnvironment))
			'results in valid cache': (shellEnvironment, error, result) ->
				assert(shellEnvironment.isCacheValid())
		'without cache period':
			topic: ->
				shellEnvironment = new ShellEnvironment(cachePeriod: false)
				shellEnvironment.getEnvironment (this.callback.bind(null, shellEnvironment))
			'results in no cache': (shellEnvironment, error, result) ->
				assert(!shellEnvironment.isCacheValid())
	.export(module)
