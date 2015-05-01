ChildProcess = require 'child_process'

class ShellEnvironment
  loginEnvironment: (callback) ->
    # I tried using ChildProcess.execFile but there is no way to set detached and this causes the child shell to lock up. This command runs an interactive login shell and executes the export command to get a list of environment variables. We then use these to run the script:
    child = ChildProcess.spawn process.env.SHELL, ['-ilc', 'env'],
      # This is essential for interactive shells, otherwise it never finishes:
      detached: true,
      # We don't care about stdin, stderr can go out the usual way:
      stdio: ['ignore', 'pipe', process.stderr]
    
    # We buffer stdout:
    buffer = ''
    child.stdout.on 'data', (data) -> buffer += data
    
    # When the process finishes, extract the environment variables and pass them to the callback:
    child.on 'close', (code, signal) ->
      environment = {}
      for definition in buffer.split('\n')
        [key, value] = definition.trim().split('=', 2)
        environment[key] = value if key != ''
      callback(null, environment)
    
    child.on 'error', (error) ->
      callback(error, null)
    
    return null

module.exports = new ShellEnvironment
