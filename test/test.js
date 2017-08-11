/** @babel */

const vows = require('vows');
const assert = require('assert');

const ShellEnvironment = require('../lib/index');

vows
	.describe('Loading shell environment variables')
	.addBatch({
		'when loading from login shell': {
			topic() {
				return ShellEnvironment.loginEnvironment(this.callback);
			},
			'results in a valid path'(error, result) {
				return assert(result.PATH);
			},
			'results in a valid home'(error, result) {
				return assert(result.HOME);
			}
		}}).addBatch({
		'when loading with invalid command': {
			topic() {
				const shellEnvironment = new ShellEnvironment({command: 'borked'});
				return shellEnvironment.getEnvironment(this.callback);
			},
			'results in error'(error, result) {
				return assert(error);
			}
		}}).addBatch({
		'with cache period': {
			topic() {
				const shellEnvironment = new ShellEnvironment({cachePeriod: 10});
				return shellEnvironment.getEnvironment((this.callback.bind(null, shellEnvironment)));
			},
			'results in valid cache'(shellEnvironment, error, result) {
				return assert(shellEnvironment.isCacheValid());
			}
		},
		'without cache period': {
			topic() {
				const shellEnvironment = new ShellEnvironment({cachePeriod: false});
				return shellEnvironment.getEnvironment((this.callback.bind(null, shellEnvironment)));
			},
			'results in no cache'(shellEnvironment, error, result) {
				return assert(!shellEnvironment.isCacheValid());
			}
		}}).addBatch({
		'with shared shell environment': {
			topic() {
				return ShellEnvironment.sharedShellEnvironment();
			},
			'should expose cache period'(topic) {
				return assert.equal(topic.cachePeriod, 1);
			}
		}}).export(module);
