module.exports = ->

	@Given /^a seller has created an item$/, ->
		@AuthenticationHelper.createAccount()

	@Given /^I have already created an account$/, ->
		@AuthenticationHelper.createAccount()
	
	@Given /^I login with my username and password$/, ->
		@AuthenticationHelper.login()
	
	@When /^I navigate to the item content page$/, ->
		client.url process.env.ROOT_URL + 'chapter-1
	
	@Then /^I am able to create my account$/, ->
		
		client.waitForExist '#enroll-account-password'
		client.setValue '#enroll-account-password', 'letme1n'
		client.click '#login-buttons-enroll-account-button'
		client.waitForExist '#login-name-link'
		expect(client.isVisible('#login-name-link')).toBe true
	
	@Then /^I am able to access my content$/, ->
		
		client.url process.env.ROOT_URL + 'chapter-1'
		client.waitForExist '#premium-content'
		expect(client.isVisible('#premium-content')).toBe true