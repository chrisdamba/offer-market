Feature: Make an offer

  As a user
  I want to make an offer on an item
  So that I can manage the item before I check out

  Background: Seller created an item
    Given a seller has created an item

  @ignore
  Scenario: authenticated user can make a private offer
    Given I have already created an account
    And I login with my username and password
    When I navigate to the item content page
    And I can see my premium content
    And I click "Make an offer"
    Then the page should redirect user to make a private offer 
