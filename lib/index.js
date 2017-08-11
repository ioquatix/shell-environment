/** @babel */

const ChildProcess = require('child_process');
const Locale = require('os-locale');

class ShellEnvironment {
	// options can include `cachePeriod`, which could be null or an integral number of seconds to cache the environment for, and `command` which is a string command to execute which should output key=value environment variables, defaults to `env`.
	constructor(options) {
		if (options && options.cachePeriod !== null) {
			this.cachePeriod = options.cachePeriod;
		} else {
			// Default to 1 second cache:
			this.cachePeriod = 1;
		}
		
		if (options && options.command) {
			this.command = options.command;
		} else {
			this.command = 'env';
		}
	}
	
	// Returns true if the environment cache is valid.
	isCacheValid() {
		// have a cache                              # and cache isn't too old
		return (this.environmentCache != null) && (this.environmentCacheDate != null) && ((new Date() - this.environmentCacheDate) < this.cachePeriod);
	}
	
	// Update the environment cache.
	setCachedEnvironment(environment) {
		if (environment && this.cachePeriod) {
			this.environmentCache = environment;
			return this.environmentCacheDate = new Date();
		}
	}
	
	// This function fetches the login environment implements any caching behaviour.
	getEnvironment(callback) {
		if (this.isCacheValid()) {
			callback(null, this.environmentCache);
		} else {
			this.getBestEnvironment((error, environment) => {
				this.setCachedEnvironment(environment);
				return callback(error, environment);
			});
		}
		
		return undefined;
	}
	
	// Get the login environment from the shell if possible, if that fails return process.env which is the next best.
	getBestEnvironment(callback) {
		// On platforms that don't have a shell, we just return process.env (e.g. Windows).
		if (!process.env.SHELL) {
			callback(null, process.env);
		}
		
		return this.getLoginEnvironmentFromShell(function(error, environment) {
			if (!environment) {
				console.warn(`ShellEnvironment.getBestEnvironment: ${error}`);
				environment = Object.assign({}, process.env);
			}
			
			if (!environment.LANG) {
				Locale().then((locale) => {
					environment.LANG = `${locale}.UTF-8`
					console.log(`ShellEnvironment.getBestEnvironment: LANG=${environment.LANG}`)
					callback(error, environment);
				}).catch((error) => {
					callback(error, environment);
				})
			} else {
				callback(error, environment);
			}
		});
	}
	
	// Get the login environment by running env within a login shell, and parsing the results.
	getLoginEnvironmentFromShell(callback) {
		// I tried using ChildProcess.execFile but there is no way to set detached and this causes the child shell to lock up. This command runs an interactive login shell and executes the export command to get a list of environment variables. We then use these to run the script:
		const child = ChildProcess.spawn(process.env.SHELL, ['-ilc', this.command + ">&3"], {
			// This is essential for interactive shells, otherwise it never finishes:
			detached: true,
			// We don't care about stdin, stderr can go out the usual way:
			stdio: ['ignore', 'ignore', process.stderr, 'pipe']
		});
		
		// We buffer stdout:
		let outputBuffer = '';
		child.stdio[3].on('data', data => outputBuffer += data);
		
		// When the process finishes, extract the environment variables and pass them to the callback:
		child.on('close', function(code, signal) {
			if (code !== 0) {
				return callback(`child process exited with non-zero status ${code}`);
			} else {
				const environment = {};
				for (let definition of Array.from(outputBuffer.split('\n'))) {
					const [key, value] = Array.from(definition.trim().split('=', 2));
					if (key !== '') { environment[key] = value; }
				}
				return callback(null, environment);
			}
		});
		
		return child.on('error', function(error) {
			console.log('error', error);
			return callback(`child process failed with ${error}`);
		});
	}
	
	static sharedShellEnvironment() {
		return this.shellEnvironment || (this.shellEnvironment = new ShellEnvironment());
	}
	
	// existing syntax, this is a static class method
	static loginEnvironment(callback) {
		return this.sharedShellEnvironment().getEnvironment(callback);
	}
}

module.exports = ShellEnvironment