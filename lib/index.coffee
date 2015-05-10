
ChildProcess = require 'child_process'

class ShellEnvironment
	# options can include `cachePeriod`, which could be null or an integral number of seconds to cache the environment for, and `command` which is a string command to execute which should output key=value environment variables, defaults to `env`.
	constructor: (options) ->
		if options? and options.cachePeriod?
			@cachePeriod = options.cachePeriod
		else
			# Default to 1 second cache:
			@cachePeriod = 1
		
		if options? and options.command?
			@command = options.command
		else
			@command = 'env'
	
	# Returns true if the environment cache is valid.
	isCacheValid: ->
		# have a cache                              # and cache isn't too old
		@environmentCache? and @environmentCacheDate? and (new Date() - @environmentCacheDate) < @cachePeriod
	
	# Update the environment cache.
	setCachedEnvironment: (environment) ->
		if environment and @cachePeriod
			@environmentCache = environment
			@environmentCacheDate = new Date()
	
	# This function fetches the login environment implements any caching behaviour.
	getEnvironment: (callback) ->
		if @isCacheValid()
			callback(null, @environmentCache)
		else
			@getBestEnvironment (error, environment) =>
				@setCachedEnvironment(environment)
				callback(error, environment)
		
		return undefined
	
	# Get the login environment from the shell if possible, if that fails return process.env which is the next best.
	getBestEnvironment: (callback) ->
		@getLoginEnvironmentFromShell (error, environment) ->
			if environment
				callback(null, environment)
			else
				console.warn("ShellEnvironment: #{error}" )
				callback(error, process.env)
	
	# Get the login environment by running env within a login shell, and parsing the results.
	getLoginEnvironmentFromShell: (callback) ->
		# I tried using ChildProcess.execFile but there is no way to set detached and this causes the child shell to lock up. This command runs an interactive login shell and executes the export command to get a list of environment variables. We then use these to run the script:
		child = ChildProcess.spawn process.env.SHELL, ['-ilc', @command + ">&3"],
			# This is essential for interactive shells, otherwise it never finishes:
			detached: true,
			# We don't care about stdin, stderr can go out the usual way:
			stdio: ['ignore', 'ignore', process.stderr, 'pipe']
		
		# We buffer stdout:
		outputBuffer = ''
		child.stdio[3].on 'data', (data) -> outputBuffer += data
		
		# When the process finishes, extract the environment variables and pass them to the callback:
		child.on 'close', (code, signal) ->
			if code != 0
				callback("child process exited with non-zero status #{code}")
			else
				environment = {}
				for definition in outputBuffer.split('\n')
					[key, value] = definition.trim().split('=', 2)
					environment[key] = value if key != ''
				callback(null, environment)
		
		child.on 'error', (error) ->
			console.log('error', error)
			callback("child process failed with #{error}")
	
	# existing syntax, this is a static class method
	@loginEnvironment: (callback) ->
		@shellEnvironment ||= new ShellEnvironment()
		@shellEnvironment.getEnvironment(callback)

module.exports = ShellEnvironment
