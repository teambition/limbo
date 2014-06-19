all: test

test:
	@NODE_ENV=mocha ./node_modules/.bin/mocha --reporter spec test/index.js

.PHONY: all test
