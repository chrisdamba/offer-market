###
# onCreateUser
# a special meteor hook to default user info on create
# see: http://docs.meteor.com/#/full/accounts_oncreateuser
# see: hooks.coffee for additional collection hooks
###
###Accounts.onCreateUser (options, user) ->
	
	unless user.emails then user.emails = []
	# add default role for all users
	# Roles.addUsersToRoles user, 'guest', OfferMarket.getShopId()
	# see: https://github.com/alanning/meteor-roles/issues/79
	unless user.roles
		shopId = OfferMarket.getShopId()
		shop = OfferMarket.getCurrentShop()
		user.roles = {}
		user.roles[shopId] = shop?.defaultRoles || [ "guest", "account/profile" ]

	# TODO: only use accounts for managing profiles
	for service, profile of user.services
		if !user.username and profile.name then user.username = profile.name
		if profile.email then user.emails.push {'address': profile.email}

	# clone into and create our user's account
	account = _.clone(user)
	account.userId = user._id
	accountId = OfferMarket.Collections.Accounts.insert(account)
	OfferMarket.Events.info "Created account: " + accountId + " for user: " + user._id

	# return user to meteor accounts
	user###

###
# Account Methods
###
Meteor.methods
	###
	# add new addresses to an account
	###
	addressBookAdd: (doc, accountId) ->
		@unblock()
		check doc, OfferMarket.Schemas.Address
		check accountId, String
		OfferMarket.Schemas.Address.clean(doc)

		if doc.isShippingDefault or doc.isBillingDefault
			# set shipping default & clear existing
			if doc.isShippingDefault
				OfferMarket.Collections.Accounts.update
					"_id": accountId
					"profile.addressBook.isShippingDefault": true
				,
					$set:
						"profile.addressBook.$.isShippingDefault": false

			# set billing default & clear existing
			if doc.isBillingDefault
				OfferMarket.Collections.Accounts.update
					'_id': accountId
					"profile.addressBook.isBillingDefault": true
				,
					$set:
						"profile.addressBook.$.isBillingDefault": false
		# add address book entry
		OfferMarket.Collections.Accounts.update accountId, {$addToSet: {"profile.addressBook": doc}}
		doc

	###
	# update existing address in user's profile
	###
	addressBookUpdate: (doc, accountId) ->
		@unblock()
		check doc, OfferMarket.Schemas.Address
		check accountId, String

		# reset existing address defaults
		if doc.isShippingDefault or doc.isBillingDefault
			if doc.isShippingDefault
				OfferMarket.Collections.Accounts.update
					"_id": accountId
					"profile.addressBook.isShippingDefault": true
				,
					$set:
						"profile.addressBook.$.isShippingDefault": false
			if doc.isBillingDefault
				OfferMarket.Collections.Accounts.update
					"_id": accountId
					"profile.addressBook.isBillingDefault": true
				,
					$set:
						"profile.addressBook.$.isBillingDefault": false

		# update existing address
		OfferMarket.Collections.Accounts.update
			"_id": accountId
			"profile.addressBook._id": doc._id
		,
			$set:
				"profile.addressBook.$": doc
		doc

	###
	# invite new admin users
	# (not consumers) to secure access in the dashboard
	# to permissions as specified in packages/roles
	###
	inviteShopMember: (shopId, email, name) ->
		check shopId, String
		check email, String
		check name, String
		@unblock()
		# get the shop first
		shop = Shops.findOne shopId
		# check permissions
		unless OfferMarket.hasOwnerAccess(shop)
			throw new Meteor.Error 403, "Access denied"

		# all params are required
		if shop and email and name
			currentUserName = Meteor.user()?.profile?.name || Meteor.user()?.username || "Admin"
			user = Meteor.users.findOne {"emails.address": email}
			unless user # user does not exist, invite user
				userId = Accounts.createUser
					email: email
					username: name
				user = Meteor.users.findOne(userId)
				unless user
					throw new Error("Can't find user")
				token = Random.id()
				Meteor.users.update userId,
					$set:
						"services.password.reset":
							token: token
							email: email
							when: new Date()
				# compile mail template
				SSR.compileTemplate('shopMemberInvite', Assets.getText('server/email/templates/shopMemberInvite.html'))
				try
					inviteEmail =
						to: email
						from: currentUserName + " <" + shop.emails[0] + ">"
						subject: "You have been invited to join " + shop.name
						html: SSR.render 'shopMemberInvite',
							homepage: Meteor.absoluteUrl()
							shop: shop
							currentUserName: currentUserName
							invitedUserName: name
							url: Accounts.urls.enrollAccount(token)

					OfferMarket.Services.Account.sendEmail inviteEmail
				catch
					throw new Meteor.Error 403, "Unable to send invitation email."
			# existing user, send notification
			else
				# compile mail template
				SSR.compileTemplate('shopMemberInvite', Assets.getText('server/email/templates/shopMemberInvite.html'))
				try
					notificationEmail =
						to: email
						from: currentUserName + " <" + shop.emails[0] + ">"
						subject: "You have been invited to join the " + shop.name
						html: SSR.render 'shopMemberInvite',
							homepage: Meteor.absoluteUrl()
							shop: shop
							currentUserName: currentUserName
							invitedUserName: name
							url: Meteor.absoluteUrl()

					OfferMarket.Services.Account.sendEmail notificationEmail
				catch
					throw new Meteor.Error 403, "Unable to send invitation email."
		else
			throw new Meteor.Error 403, "Access denied"
		true

	### 
	# check the email sent from the client, picking out
	# a standard email vs. an OAuth email.
	###
	determineEmail: (user)->
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

	###
	# send an email to consumers on sign up
	###
	sendWelcomeEmail: (shopId, userId) ->
		check shop, Object
		@unblock()

		email = Meteor.user(userId).emails[0].address
		SSR.compileTemplate('welcomeNotification', Assets.getText('server/email/templates/welcomeNotification.html'))
		welcomeEmail =
			to: email
			from: shop.emails[0]
			subject: "Welcome to " + shop.name + "!"
			html: SSR.render 'welcomeNotification',
				homepage: Meteor.absoluteUrl()
				shop: shop
				user: Meteor.user()
		OfferMarket.Services.Account.sendEmail email
		true

	###
	# @summary addUserPermissions
	# @param {Array|String} permission
	#               Name of role/permission.  If array, users
	#               returned will have at least one of the roles
	#               specified but need not have _all_ roles.
	# @param {String} [group] Optional name of group to restrict roles to.
	#                         User's Roles.GLOBAL_GROUP will also be checked.
	# @returns {Boolean} success/failure
	###
	addUserPermissions: (userId, permissions, group) ->
		check userId, Match.OneOf(String, Array)
		check permissions, Match.OneOf(String, Array)
		check group, Match.Optional(String)
		@unblock()

		# for roles
		try
			Roles.addUsersToRoles(userId, permissions, group)
		catch e
			OfferMarket.Events.info e

	###
	# removeUserPermissions
	###
	removeUserPermissions: (userId, permissions, group) ->
		check userId, String
		check permissions, Match.OneOf(String, Array)
		check group, Match.Optional(String, null)
		@unblock()

		# for shop member data
		try
			Roles.removeUsersFromRoles(userId, permissions, group)
		catch e
			OfferMarket.Events.info e

	###
	# setUserPermissions
	###
	setUserPermissions: (userId, permissions, group) ->
		check userId, String
		check permissions, Match.OneOf(String, Array)
		check group, Match.Optional(String)
		@unblock()

		# for shop member data
		try
			Roles.setUserRoles(userId, permissions, group)
		catch e
			OfferMarket.Events.info e
