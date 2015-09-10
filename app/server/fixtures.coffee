###
# Fixtures is a global server object that it can be reused in packages
# assumes collection data in reaction-core/private/data, optionally jsonFile
# use jsonFile when calling from another package, as we can't read the assets from here
###
PackageFixture = ->
	# loadData inserts json into collections on app initilization
	# ex:
	#   jsonFile =  Assets.getText("private/data/Shipping.json")
	#   Fixtures.loadData OfferMarket.Collections.Shipping, jsonFile
	#
	loadData: (collection, jsonFile) ->
		#check collection, OfferMarket.Schemas[collection._name]
		check jsonFile, Match.Optional(String)
		if collection.find().count() > 0 then return

	 # load fixture data
		OfferMarket.Events.info "Loading fixture data for " + collection._name
		unless jsonFile
			json = EJSON.parse Assets.getText("data/" + collection._name + ".json")
		else
			json = EJSON.parse jsonFile

		# loop through and import
		for item, index in json									
			collection.insert item, (error, result) ->				
				if error
					OfferMarket.Events.warn "Error adding #{index} to #{collection._name}" , item, error
					return false
		if index > 0
			OfferMarket.Events.info "Success adding  #{index} to #{collection._name}"

		else
			OfferMarket.Events.info "No data imported to #{collection._name}" 


###
# instantiate fixtures
###
@Fixtures = new PackageFixture

###
# local helper for creating admin users
###
getDomain = (url) ->
	unless url then url = process.env.ROOT_URL
	domain = url.match(/^https?\:\/\/([^\/:?#]+)(?:[\/:?#]|$)/i)[1]
	return domain

###
# Method that creates default admin user
###
OfferMarketRegistry.createDefaultAdminUser = ->
	# options from set env variables
	options = {}
	options.email = process.env.METEOR_EMAIL #set in env if we want to supply email
	options.username = process.env.METEOR_USER
	options.password = process.env.METEOR_AUTH
	domain = getDomain()

	# options from mixing known set ENV production variables
	if process.env.METEOR_EMAIL
		url = process.env.MONGO_URL #pull from default db connect string
		options.username = "Owner"
		unless options.password then options.password = url.substring(url.indexOf("/") + 2,url.indexOf("@")).split(":")[1]
		OfferMarket.Events.warn ("\nIMPORTANT! DEFAULT USER INFO (ENV)\n  EMAIL/LOGIN: " + options.email + "\n  PASSWORD: " + options.password + "\n")
	else
		# from Meteor.settings or random options if nothing has been set
		options.username = Meteor.settings?.reaction?.METEOR_USER || "Owner"
		options.password = Meteor.settings?.reaction?.METEOR_AUTH || Random.secret(8)
		options.email = Meteor.settings?.reaction?.METEOR_EMAIL || Random.id(8).toLowerCase() + "@" + domain
		OfferMarket.Events.warn ("\nIMPORTANT! DEFAULT USER INFO (RANDOM)\n  EMAIL/LOGIN: " + options.email + "\n  PASSWORD: " + options.password + "\n")

	# newly created admin user
	accountId = Accounts.createUser options
	shopId = OfferMarket.getShopId()





###
# load core fixture data
###
OfferMarketRegistry.loadFixtures = ->
	# Load data from json files
	Fixtures.loadData OfferMarket.Collections.Shops
	Fixtures.loadData OfferMarket.Collections.Products
	Fixtures.loadData OfferMarket.Collections.Tags
	#	Fixtures.loadI18n OfferMarket.Collections.Translations
	

	# create default admin user account
	OfferMarketRegistry.createDefaultAdminUser() unless Meteor.users.find().count()


# Function: Create Service Configuration
# Here, we create a function to help us reset and create our third-party login
# configurations to keep our code as DRY as possible.
OfferMarketRegistry.createServiceConfiguration = (service,clientId,secret)->
	ServiceConfiguration.configurations.remove(
			service: service
	)
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
