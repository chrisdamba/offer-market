describe 'Account Service', ->

	###describe 'createAccount', ->
		
		it 'creates an account, stores the stripe customer id and invites the user to enroll', ->
			
			spyOn(Accounts, 'createUser').and.returnValue 'someId'
			spyOn Accounts, 'sendEnrollmentEmail'
			
			OfferMarket.Services.Account.createAccount 'me@example.com', stripeCustomerId: 'cust_00001'
			
			expect(Accounts.createUser).toHaveBeenCalledWith
				email: 'me@example.com'
				profile: stripeCustomerId: 'cust_00001'
			
			expect(Accounts.sendEnrollmentEmail).toHaveBeenCalledWith 'someId'

	describe 'sendEmail', ->

		it 'sends an email to a user', ->

			spyOn Email, 'send'

			userData = 
				to: 'you@test.com'
				from: 'test@example.com'
				subject: 'Test'
				text: 'This is a test'

			OfferMarket.Services.Account.sendEmail userData

			expect(Email.send).toHaveBeenCalledWith
				to: 'you@test.com'
				from: 'test@example.com'
				subject: 'Test'
				text: 'This is a test'

	describe 'determineEmail', ->

		describe 'checks the email sent from the client and picks out a standard email vs. an OAuth email.', ->

			describe 'when the user email is standard', ->

				it 'should return a standard email', ->

					userData = 
						emails: [
							address: 'client@abc.com'
						]


					emailAddress = OfferMarket.Services.Account.determineEmail userData

					expect(emailAddress).toEqual('client@abc.com')

			describe 'when the user email is OAUth', ->				

					describe 'and email service is facebook', ->

						it 'should return a facebook email', ->

							userData = 
								services: 
									facebook:
										email: 'user@facebook.com'


							emailAddress = OfferMarket.Services.Account.determineEmail userData

							expect(emailAddress).toEqual('user@facebook.com')

					describe 'and email service is github', ->

						it 'should return a github email', ->

							userData = 
								services: 
									github:
										email: 'user@github.com'


							emailAddress = OfferMarket.Services.Account.determineEmail userData

							expect(emailAddress).toEqual('user@github.com')

					describe 'and email service is google', ->

						it 'should return a google email', ->

							userData = 
								services: 
									google:
										email: 'user@googlemail.com'


							emailAddress = OfferMarket.Services.Account.determineEmail userData

							expect(emailAddress).toEqual('user@googlemail.com')

					describe 'and email service is google', ->

						it 'should return a google email', ->

							userData = 
								services: 
									google:
										email: 'user@googlemail.com'


							emailAddress = OfferMarket.Services.Account.determineEmail userData

							expect(emailAddress).toEqual('user@googlemail.com')

					describe 'and email service is twitter', ->

						it 'should return null', ->

							userData = 
								services: 
									twitter:
										email: 'twitterhandle'


							emailAddress = OfferMarket.Services.Account.determineEmail userData

							expect(emailAddress).toEqual(null)


			describe 'when the user object is other', ->	

				it 'should return null', ->

					userData = {}

					emailAddress = OfferMarket.Services.Account.determineEmail userData

					expect(emailAddress).toEqual(null)###