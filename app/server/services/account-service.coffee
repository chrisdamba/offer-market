OfferMarket.Services.Account =

	createAccount: (email, profile) ->
		newUserId = Accounts.createUser(
			email: email
			profile: profile
		)
		
		Accounts.sendEnrollmentEmail newUserId
	
	sendEmail: (obj) ->
		Email.send
			to: obj.to
			from: obj.from
			subject: obj.subject
			text: obj.text

	determineEmail: (user) ->
		if user.emails
			emailAddress = user.emails[0].address
		else if user.services
			services = user.services
			emailAddress = switch
				when services.facebook then services.facebook.email
				when services.github then services.github.email
				when services.google then services.google.email
				when services.twitter then null
				else null
		else
			null
