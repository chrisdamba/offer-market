module.exports = ->

	@Given /^A seller has created a product$/, ->
		@server.call 'fixtures/seedData'

	@Given /^I am not logged in$/, ->
		@AuthenticationHelper.logout()
	
	@Given /^I login with my username and password$/, ->
		@AuthenticationHelper.login()
	
	@When /^I navigate to the make offer page$/, ->
		@client.url process.env.ROOT_URL + 'offer'
	
	@Then /^I cannot see offer options$/, ->
		@client.waitForExist '.popup-login' #so we know the page has loaded in non-logged in mode
		#expect(@client.isVisible('.popup-login')).toBe(true)
		#expect(@client.isVisible('#make-offer')).toBe(false)
