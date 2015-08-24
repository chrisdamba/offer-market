###
# Application Startup
# OfferMarket Server Configuration
###

###
# configure bunyan logging module for server
# See: https://github.com/trentm/node-bunyan#levels
###
isDebug = Meteor?.settings?.public?.isDebug || process.env.REACTION_DEBUG || "INFO"

# acceptable levels
levels = ["FATAL","ERROR","WARN", "INFO", "DEBUG", "TRACE"]

# if debug is true, or NODE_ENV development environment and not false
# set to lowest level, or any defined level set to level
if isDebug is true or ( process.env.NODE_ENV is "development" and isDebug isnt false )
	# set logging levels from settings
	if typeof isDebug isnt 'boolean' and typeof isDebug isnt 'undefined' then isDebug = isDebug.toUpperCase()
	unless _.contains levels, isDebug
		isDebug = "WARN"

# Define bunyan levels and output to Meteor console
# init logging stream
if process.env.VELOCITY_CI is "1" #format screws with testing output
	formatOut = process.stdout
else
	formatOut = logger.format({ outputMode: 'short', levelInString: false})

# enable logging
OfferMarket.Events = logger.bunyan.createLogger(
	name: 'core'
	stream: (unless isDebug is "DEBUG" then formatOut else process.stdout )
	level: 'debug')

# set bunyan logging level
OfferMarket.Events.level(isDebug)


###
# OfferMarket methods (server)
###
_.extend OfferMarket,
	init: ->
		try
			#OfferMarketRegistry.loadFixtures()
		catch e
			throw new Meteor.Error 200, e
		return true

	getCurrentShopCursor: (client) ->
		domain = @getDomain(client)
		cursor = Shops.find({domains: domain}, {limit: 1})
		if !cursor.count()
			OfferMarket.Events.info "Reaction Configuration: Add a domain entry to shops for: ", domain
		return cursor

	getCurrentShop: (client) ->
		cursor = @getCurrentShopCursor(client)
		return cursor.fetch()[0]

	getShopId: (client) ->
		return @getCurrentShop(client)?._id

	getDomain: (client) ->
		#TODO: eventually we want to use the host domain to determine
		#which shop from the shops collection to use here, hence the unused client arg
		return Meteor.absoluteUrl().split('/')[2].split(':')[0]

	# permission check
	hasPermission: (permissions) ->
		# shop specific check
		if Roles.userIsInRole Meteor.userId(), permissions, @getShopId()
			return true
		# global roles check
		else if Roles.userIsInRole Meteor.userId(), permissions, Roles.GLOBAL_GROUP
			return true
		for shop in @getSellerShopId()
			if Roles.userIsInRole Meteor.userId(), permissions, shop
				return true
		return false

	# owner access
	hasOwnerAccess: (client) ->
		ownerPermissions = ['owner']
		return @hasPermission ownerPermissions

	# admin access
	hasAdminAccess: (client) ->
		adminPermissions = ['owner','admin']
		return @hasPermission adminPermissions

	# dashboard access
	hasDashboardAccess: (client) ->
		dashboardPermissions = ['owner','admin','dashboard']
		return @hasPermission dashboardPermissions

	# return the logged in user's shop[s] if he owns any or if he is an admin -> used in multivendor
	getSellerShopId: (client) ->
		return Roles.getGroupsForUser Meteor.userId(), 'admin'

	# sets the shop mail server auth info
	# load priority: param, shop data, enviroment, settings
	configureMailUrl: (user, password, host, port) ->
		shopMail = OfferMarket.Collections.Packages.findOne({shopId: @getShopId(), name: "core"}).settings.mail
		# use configurMailUrl as a function
		if user and password and host and port
			return process.env.MAIL_URL = "smtp://" + user + ":" + password + "@" + host + ":" + port + "/"
		# shops configuration
		else if shopMail.user and shopMail.password and shopMail.host and shopMail.port
			OfferMarket.Events.info "setting default mail url to: " + shopMail.host
			return process.env.MAIL_URL =
					"smtp://" + shopMail.user + ":" + shopMail.password + "@" + shopMail.host + ":" + shopMail.port + "/"
		# Meteor.settings isn't standard, if you add it, respect over default
		else if Meteor.settings.MAIL_URL and not process.env.MAIL_URL
			return process.env.MAIL_URL = Meteor.settings.MAIL_URL
		# default meteor env config
		unless process.env.MAIL_URL
			OfferMarket.Events.warn 'Mail server not configured. Unable to send email.'
			return false

###
# Execute start up fixtures
###
Meteor.startup ->
	
	# Environment Variable: MAIL_URL
	process.env.MAIL_URL = "Insert your own MAIL_URL from your email provider here."
	# Function: Create Service Configuration
	# Here, we create a function to help us reset and create our third-party login
	# configurations to keep our code as DRY as possible.
	createServiceConfiguration = (service, clientId, secret)->
		ServiceConfiguration.configurations.remove	service: service
		
		# Note: here we have to do a bit of light testing on our service argument.
		# Facebook and Twitter use different key names for their OAuth client ID,
		# so we need to update our passed object accordingly before we insert it
		# into our configurations.
		config =
			generic:
				service: service
				clientId: clientId
				secret: secret
			facebook:
				service: service
				appId: clientId
				secret: secret
			twitter:
				service: service
				consumerKey: clientId
				secret: secret

		# To simplify this a bit, we make use of a case/switch statement. This is
		# a shorthand way to say "when the service argument is equal to <x> do this."
		# This is also available in plain JavaScript, but the CoffeeScript version
		# is a bit more "literal" and easier to read.
		switch service
			when 'facebook' then ServiceConfiguration.configurations.insert(config.facebook)
			when 'twitter' then ServiceConfiguration.configurations.insert(config.twitter)
			else ServiceConfiguration.configurations.insert(config.generic)

	###
		Configure Third-Party Login Services
		Note: We're passing the Service Name, Client Id, and Secret. These values
		are obtained by visiting each of the given services (URLs listed below) and
		registering your application.
	###

	# Facebook
	createServiceConfiguration('facebook', 'Insert your appId here.', 'Insert your secret here.')
	# Generate your Client & Secret here: https://developers.facebook.com/apps/

	# GitHub
	createServiceConfiguration('github', 'Insert your clientId here.', 'Insert your secret here.')
	# Generate your Client & Secret here: https://github.com/settings/applications

	# Google
	createServiceConfiguration('google', 'Insert your clientId here.', 'Insert your secret here.')
	# Generate your Client & Secret here: https://console.developers.google.com

	# Twitter
	createServiceConfiguration('twitter', '0K1q4SjsxkJ9L5bIyOamyvZOo', 'H2OdnveKIVmqIr6cFBmOwEm74kQbGgyt4vR7mjd05Y0aQJVPsN')
	# Generate your Client & Secret here: https://apps.twitter.com/

	###
		Generate Test Accounts
		Creates a collection of test accounts automatically on startup.
	###

	# Create an array of user accounts.
	users = [
		{ name: "Admin", email: "chridam@gmail.com", password: "Che55!B0ard" }
	]

	# Loop through array of user accounts.
	for user in users

		# Check if the user already exists in the DB.
		checkUser = Meteor.users.findOne({"emails.address": user.email});

		# If an existing user is not found, create the account.
		if not checkUser

			id = Accounts.createUser
				email: user.email
				password: user.password
				profile:
					name: user.name

	# notifiy that we're done with initialization
	OfferMarket.init()
	OfferMarket.Events.info "OfferMarket initialization finished. "