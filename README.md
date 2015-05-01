# Shell Environment

This package allows you to easily grab the login environment for the user even if the current process was launched from a GUI with little or no environment specified. This allows things like `rvm` to run correctly.

This was originally developed for Atom's [Script Runner](https://atom.io/packages/script-runner). Please feel free to suggest changes or improvements. PRs welcome.

## Usage

A simple coffee script example:

	ShellEnvironment = require 'shell-environment'
	
	ShellEnvironment.loginEnvironment (error, environment) =>
		if environment
			child = ChildProcess.spawn(args[0], args.slice(1), env: environment)
		else
			console.log(error)

### Running Tests

First install all dependencies:

	npm install

Then run tests:

	./node_modules/.bin/vows --spec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
