###
		Startup
		Collection of methods and functions to run on server startup.
###

###
# configure bunyan logging module for server
# See: https://github.com/trentm/node-bunyan#levels
###
isDebug = Meteor?.settings?.public?.isDebug || process.env.REACTION_DEBUG || "INFO"

# acceptable levels
levels = ["FATAL", "ERROR", "WARN", "INFO", "DEBUG", "TRACE"]

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

_.extend OfferMarket,
	init: ->
		try
			OfferMarketRegistry.loadFixtures()
		catch e
			throw new Meteor.Error 200, e
		return true

	getCurrentShopCursor: (client) ->
		domain = @getDomain(client)
		cursor = Shops.find({domains: domain}, {limit: 1})
		if !cursor.count()
			OfferMarket.Events.info "Configuration: Add a domain entry to shops for: ", domain
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

Meteor.startup ->
	# Environment Variable: MAIL_URL
	#process.env.MAIL_URL = "Insert your own MAIL_URL from your email provider here."
	
	###
			Configure Third-Party Login Services
			Note: We're passing the Service Name, Client Id, and Secret. These values
			are obtained by visiting each of the given services (URLs listed below) and
			registering your application.
	###

	# Facebook
	#OfferMarketRegistry.createServiceConfiguration('facebook', 'Insert your appId here.', 'Insert your secret here.')
	# Generate your Client & Secret here: https://developers.facebook.com/apps/

	# Google
	#OfferMarketRegistry.createServiceConfiguration('google', 'Insert your clientId here.', 'Insert your secret here.')
	# Generate your Client & Secret here: https://console.developers.google.com

	# Twitter
	#OfferMarketRegistry.createServiceConfiguration('twitter', '0K1q4SjsxkJ9L5bIyOamyvZOo', 'H2OdnveKIVmqIr6cFBmOwEm74kQbGgyt4vR7mjd05Y0aQJVPsN')
	# Generate your Client & Secret here: https://apps.twitter.com/



	OfferMarket.init()
	OfferMarket.Events.info "Offer Market initialization finished. "