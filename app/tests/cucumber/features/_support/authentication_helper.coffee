module.exports = ->
	@Before ->
		@AuthenticationHelper =
			login: ->
				client.waitForExist 'a.open-popup'
				client.click 'a.open-popup'
				client.setValue '#login-email', 'me@example.com'
				client.setValue '#login-password', 'letme1n'
				client.click '.btn-sign-in'
				client.waitForExist '#login-name-link'
				
			logout: ->
				client.executeAsync (done) ->
					Meteor.logout done					
				
			createAccount: (profile) ->
				profile = profile or periodEnd: Math.floor((new Date).getTime() / 1000)
				server.call 'fixtures/createAccount',
					email: 'me@example.com'
					password: 'letme1n'
					profile: profile
					
			createAccountAndLogin: (profile) ->
				@createAccount profile
				@login()