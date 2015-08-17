# You can include npm dependencies for support files in tests/cucumber/package.json
_ = require('underscore')

module.exports = ->
  # You can use normal require here, cucumber is NOT run in a Meteor context (by design)
	url = require 'url'

	@Given /^I am a new user$/, ->
		# no callbacks! DDP has been promisified so you can just return it
		@server.call 'fixtures/reset'
		# this.ddp is a connection to the mirror
	@When /^I navigate to "([^"]*)"$/, (relativePath) ->
		# WebdriverIO supports Promises/A+ out the box, so you can return that too
		@client.url url.resolve(process.env.ROOT_URL, relativePath)
		# process.env.ROOT_URL always points to the mirror
	@Then /^I should see the title "([^"]*)"$/, (expectedTitle) ->
		# you can use chai-as-promised in step definitions also
		@client.waitForVisible('body *').getTitle().should.become expectedTitle