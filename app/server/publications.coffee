
###
	Publications
	Data being published to the client.
###

Cart  = OfferMarket.Collections.Cart
Accounts = OfferMarket.Collections.Accounts
Discounts = OfferMarket.Collections.Discounts
Media = OfferMarket.Collections.Media
Orders = OfferMarket.Collections.Orders
Packages = OfferMarket.Collections.Packages
Products = OfferMarket.Collections.Products
Shipping =  OfferMarket.Collections.Shipping
Shops = OfferMarket.Collections.Shops
Tags = OfferMarket.Collections.Tags
Taxes = OfferMarket.Collections.Taxes
Translations = OfferMarket.Collections.Translations

###
# Reaction Server / amplify permanent sessions
# If no id is passed we create a new session
# Load the session
# If no session is loaded, creates a new one
###
@ServerSessions = new Mongo.Collection "Sessions"
Meteor.publish 'Sessions', (id) ->
	check id, Match.OneOf(String, null)

	created = new Date().getTime()
	id = ServerSessions.insert(created: created) unless id
	serverSession = ServerSessions.find(id)

	if serverSession.count() is 0
		id = ServerSessions.insert(created: created)
		serverSession = ServerSessions.find(id)
	serverSession

###
# CollectionFS - Image/Video Publication
###
Meteor.publish "Media", (shops) ->
	check shops, Match.Optional(Array)
	shopId = OfferMarket.getShopId( @)
	if shopId
		selector = {'metadata.shopId': shopId}
		## add additional shops
	if shops
		selector = {'metadata.shopId': {$in: shops}}
	Media.find selector,
		sort : {"metadata.priority" : 1}

###
# i18n - translations
###
Meteor.publish "Translations", (sessionLanguage) ->
	check sessionLanguage, String
	Translations.find({ $or: [{'i18n':'en'},{'i18n': sessionLanguage}] })

###
# userProfile
# get any user name,social profile image
# should be limited, secure information
###
Meteor.publish "UserProfile", (profileUserId) ->
	check profileUserId, Match.OneOf(String, null)
	permissions = ['dashboard/orders','owner','admin','dashboard/customers']

	if profileUserId isnt @userId
		# admin users can see some additional restricteduser details
		if @userId and (
			Roles.userIsInRole @userId, permissions, OfferMarket.getCurrentShop(@)._id or
			Roles.userIsInRole @userId, permissions, Roles.GLOBAL_GROUP
			)
			Meteor.users.find _id: profileUserId,
				fields:
					"emails": true
					"profile.firstName": true
					"profile.lastName": true
					"profile.familyName": true
					"profile.secondName": true
					"profile.name": true
					"services.twitter.profile_image_url_https": true
					"services.facebook.id": true
					"services.google.picture": true
					"services.github.username": true
					"services.instagram.profile_picture": true
		else
			OfferMarket.Events.info "user profile access denied"
			[]
	# a user can see their own user data
	else if @userId
		Meteor.users.find _id: @userId
	# prevent other access to users
	else
		[]

###
#  Packages contains user specific configuration
#  settings, package access rights
###
Meteor.publish 'Packages', (shop) ->
	shop = OfferMarket.getCurrentShop(@)
	if shop
		if Roles.userIsInRole(@userId, [
				'dashboard'
				'owner'
				'admin'
			], OfferMarket.getShopId(this) or Roles.userIsInRole(@userId, [
				'owner'
				'admin'
			], Roles.GLOBAL_GROUP))
			Packages.find shopId: shop._id
		else
			Packages.find { shopId: shop._id }, fields:
				shopId: true
				name: true
				enabled: true
				registry: true
				'settings.public': true
	else
		[]

###
# shops
###
Meteor.publish 'Shops', ->
	OfferMarket.getCurrentShopCursor(@)

###
# ShopMembers
###
Meteor.publish 'ShopMembers', ->
	permissions = ['dashboard/orders','owner','admin','dashboard/customers']
	shopId = OfferMarket.getShopId(@)
	if Roles.userIsInRole(@userId, permissions, shopId)
		Meteor.users.find({}, {fields: {_id: 1, email: 1, username: 1, roles: 1}})
	else
		OfferMarket.Events.info "ShopMembers access denied"
		[]

###
# products
###
Meteor.publish 'Products', (shops) ->
	check shops, Match.Optional(Array)
	shop = OfferMarket.getCurrentShop(@)
	if shop
		selector = {shopId: shop._id}
		## add additional shops
		if shops
			selector = {shopId: {$in: shops}}
			## check if the user is admin in any of the shops
			for shop in shops
				if Roles.userIsInRole this.userId, ['admin','createProduct'], shop._id
					shopAdmin = true
		unless Roles.userIsInRole(this.userId, ['owner'], shop._id) or shopAdmin
			selector.isVisible = true
		Products.find(selector, {sort: {title: 1}})
	else
		[]

Meteor.publish 'Product', (productId) ->
	check productId, String
	shop = OfferMarket.getCurrentShop(@) #TODO: wire in shop
	selector = {}
	selector.isVisible = true
	if Roles.userIsInRole this.userId, ['owner','admin','createProduct'], shop._id
		selector.isVisible = {$in: [true, false]}

	if productId.match /^[A-Za-z0-9]{17}$/
		selector._id = productId
	else
		selector.handle = { $regex : productId, $options:"i" }
	Products.find(selector)

###
# orders
###
Meteor.publish 'Orders', (userId) ->
	check userId, Match.Optional(String)
	# only admin can get all orders
	if Roles.userIsInRole @userId, ['admin','owner'], OfferMarket.getShopId(@)
		Orders.find shopId: OfferMarket.getShopId(@)
	else
		[]

###
# account orders
###
Meteor.publish 'AccountOrders', (sessionId, userId) ->
	check sessionId, Match.OptionalOrNull(String)
	check userId, Match.OptionalOrNull(String)
	shopId = OfferMarket.getShopId(@)
	# cure for null query match and added check
	if userId and userId isnt @userId then return []
	unless userId then userId = ''
	unless sessionId then sessionId = ''
	# publish user / session orders
	return Orders.find({'shopId': shopId, $or: [{'userId': userId}, 'sessions': $in: [ sessionId ]] })

###
# cart
###
Meteor.publish 'Cart', (sessionId, userId) ->
	check sessionId, Match.OptionalOrNull(String)
	check userId, Match.OptionalOrNull(String)
	if !sessionId then return
	shopId = OfferMarket.getShopId(@)

	# getCurrentCart returns cart cursor
	currentCart = getCurrentCart sessionId, shopId, @userId
	OfferMarket.Events.debug "Publishing cart sessionId:" + sessionId
	currentCart

###
# accounts
###
Meteor.publish 'Accounts', (sessionId, userId) ->
	check sessionId, Match.OneOf(String, null)
	check userId, Match.OneOf(String, null)

	# global owner gets it all
	if Roles.userIsInRole @userId, ['owner'], Roles.GLOBAL_GROUP
		Accounts.find()

	# shop owner / admin sees all, in shop
	else if Roles.userIsInRole @userId, ['admin','owner'], OfferMarket.getShopId(@)
		Accounts.find shopId: OfferMarket.getShopId(@)

	# returns userId (authenticated account) details only
	else
		OfferMarket.Events.debug "subscribe account", sessionId, @userId
		# get current account
		if @userId # userAccount
			accountId = OfferMarket.Collections.Accounts.findOne('userId': @userId)?._id
		else # sessionAccount
			accountId = OfferMarket.Collections.Accounts.findOne('sessions': sessionId)?._id
		unless accountId
			accountId = OfferMarket.Collections.Accounts.insert 'sessions': [sessionId], 'userId': userId

		#return accountId
		OfferMarket.Events.info "publishing account", accountId
		return OfferMarket.Collections.Accounts.find accountId

###
# tags
###
Meteor.publish "Tags", ->
	Tags.find(shopId: OfferMarket.getShopId())

###
# shipping
###
Meteor.publish "Shipping", ->
	Shipping.find(shopId: OfferMarket.getShopId())

###
# taxes
###
Meteor.publish "Taxes", ->
	Taxes.find(shopId: OfferMarket.getShopId())

###
# discounts
###
Meteor.publish "Discounts", ->
	Discounts.find(shopId: OfferMarket.getShopId())


###
# profile
###
Meteor.publish 'userData', ->
	# Cache this.userId first since we use it twice below.
	currentUser = this.userId
	# If a current user is available, find the current user and publish the
	# specified fields. Note: Meteor stores OAuth emails differently than it does
	# for accounts created using the standard accounts-password package.
	if currentUser
		Meteor.users.find({_id: currentUser}, {
			fields: {
				"services.facebook.email": 1
				"services.github.email": 1
				"services.google.email": 1
				"services.twitter.screenName": 1
				"emails.address[0]": 1
				"profile": 1
			}
		})
	else
		this.ready()