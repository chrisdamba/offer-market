Feature: Create account

	As a user
	I want to authenticate
	So that I can make an offer on an item
	
	Background: a site has been configured
		Given A seller has created a product

	@dev
	Scenario: unregisterd users cannot make an offer
		Given I am not logged in
		When I navigate to the make offer page
		Then I cannot see offer options

	@ignore
	Scenario: unregisterd users can create an account
		Given I am not logged in
		When I navigate to the log in screen
		Then I register to create an account

	@ignore
	Scenario: registered users can login to see private content
		Given I have signed up
		And I am not logged in
		When I navigate to the private content page
		And I login
		Then I can see my premium content

	@ignore
	Scenario: registered users can repurchase a subscription
		Given I am not logged in
		When I navigate to the private content page
		And I see a "Buy Now" button
		And I cannot not see premium content
