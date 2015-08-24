###
# Fixtures is a global server object that it can be reused in packages
# assumes collection data in app/private/data, optionally jsonFile
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
					OfferMarket.Events.warn "Error adding " + index + " to " + collection._name, item, error
					return false
		if index > 0
			OfferMarket.Events.info ("Success adding " + index + " items to " + collection._name)
			return
		else
			OfferMarket.Events.info ("No data imported to " + collection._name)
			return

	###
	# updates package settings, accepts json string
	# example:
	#  Fixtures.loadSettings Assets.getText("settings/reaction.json")
	#
	# This basically allows you to "hardcode" all the settings. You can change them
	# via admin etc for the session, but when the server restarts they'll
	# be restored back to the supplied json
	#
	# All settings are private unless added to `settings.public`
	#
	# Meteor account services can be added in `settings.services`
	###
	loadSettings: (json) ->
		check json, String
		validatedJson = EJSON.parse json
		# warn if this isn't an array of packages
		unless _.isArray(validatedJson[0])
			OfferMarket.Events.warn "Load Settings is not an array. Failed to load settings."
			return
		# loop through and import
		for pkg in validatedJson
			for item in pkg
				exists = OfferMarket.Collections.Packages.findOne('name': item.name)
				if exists
					result = OfferMarket.Collections.Packages.upsert(
						{ 'name': item.name }, {
							$set:
								'settings': item.settings
								'enabled': item.enabled
						},
						multi: true
						upsert: true
						validate: false)

					# add meteor auth services
					if item.settings.services
						for services in item.settings.services
							for service, settings of services
								ServiceConfiguration.configurations.upsert { service: service }, $set: settings
								OfferMarket.Events.info "service configuration loaded: " + item.name + " | " + service

					# completed loading settings
					OfferMarket.Events.info "loaded local package data: " + item.name
		return
	#
	# loadI18n for defined shops language source json
	# ex: Fixtures.loadI18n()
	#
	loadI18n: (collection = OfferMarket.Collections.Translations) ->
		languages = []
		return if collection.find().count() > 0
		# load languages from shops array
		shop = OfferMarket.Collections.Shops.findOne()
		# find every file in private/data/i18n where <i18n>.json
		OfferMarket.Events.info "Loading fixture data for " + collection._name
		# ensures that a language file is loaded if all translations are missing
		unless shop?.languages then shop.languages = [{'i18n':'en'}]

		for language in shop.languages
			json = EJSON.parse Assets.getText("data/i18n/" + language.i18n + ".json")

			for item in json
				collection.insert item, (error, result) ->
					if error
						OfferMarket.Events.warn "Error adding " + language.i18n + " to " + collection._name, item, error
						return
				OfferMarket.Events.info "Success adding " + language.i18n + " to " + collection._name
		return

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

	# add default roles and update shop with admin user
	defaultAdminRoles = ['owner','admin']
	packages = OfferMarket.Collections.Packages.find().fetch()

	# we need a contact and a domain
	Shops.update shopId,
		$addToSet:
			emails: {'address': options.email, 'verified': true}
			domains: Meteor.settings.ROOT_URL

	# add all package routes as permissions
	for pkg in packages
		for reg in pkg.registry
			defaultAdminRoles.push reg.route if reg.route
			defaultAdminRoles.push reg.name if reg.name
		defaultAdminRoles.push pkg.name
	# add all package permissions to default shop
	Meteor.call "addUserPermissions", accountId, _.uniq(defaultAdminRoles), shopId
	# global owner permissions
	Meteor.call "addUserPermissions", accountId,['owner','admin','dashboard'], Roles.GLOBAL_GROUP
	return


###
# load core fixture data
###
OfferMarketRegistry.loadFixtures = ->
	# Load data from json files
	Fixtures.loadData OfferMarket.Collections.Shops
	Fixtures.loadData OfferMarket.Collections.Products
	Fixtures.loadData OfferMarket.Collections.Tags
	Fixtures.loadI18n OfferMarket.Collections.Translations

	# if ROOT_URL update shop domain
	# for now, we're assuming the first domain is the primary
	currentDomain = Shops.findOne().domains[0]
	if currentDomain isnt getDomain()
		OfferMarket.Events.info "Updating domain to " + getDomain()
		Shops.update({domains:currentDomain},{$set:{"domains.$":getDomain()}})

	# Loop through OfferMarketRegistry.Packages object, which now has all packages added by
	# calls to register
	# removes package when removed from meteor, retriggers when package added
	unless OfferMarket.Collections.Packages.find().count() is Shops.find().count() * Object.keys(OfferMarketRegistry.Packages).length
		_.each OfferMarketRegistry.Packages, (config, pkgName) ->
			Shops.find().forEach (shop) ->
				OfferMarket.Events.info "Initializing "+ pkgName
				OfferMarket.Collections.Packages.upsert {shopId: shop._id, name: pkgName},
					$setOnInsert:
						shopId: shop._id
						enabled: !!config.autoEnable
						settings: config.settings
						registry: config.registry

		# remove unused packages
		Shops.find().forEach (shop) ->
			OfferMarket.Collections.Packages.find().forEach (pkg) ->
				unless _.has(OfferMarketRegistry.Packages, pkg.name)
					OfferMarket.Events.info ("Removing "+ pkg.name)
					OfferMarket.Collections.Packages.remove {shopId: shop._id, name: pkg.name}

	# create default admin user account
	OfferMarketRegistry.createDefaultAdminUser() unless Meteor.users.find().count()