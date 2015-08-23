###
# Cart
#
# methods to cart calculated values
# cartCount, cartSubTotal, cartShipping, cartTaxes, cartTotal
# are calculated by a transformation on the collection
# and are available to use in template as cart.xxx
# in template: {{cart.cartCount}}
# in code: OfferMarket.Collections.Cart.findOne().cartTotal()
###
OfferMarket.Helpers.cartTransform =
	
	cartCount : ->
		count = 0
		((count += items.quantity) for items in @.items) if @?.items
		count
	
	cartShipping : ->
		shipping = 0
		if @?.shipping?.shipmentMethod?.rate
			shipping = @?.shipping?.shipmentMethod?.rate
		else if @?.shipping?.shipmentMethod.length > 0
			shipping += shippingMethod.rate \
				for shippingMethod in @.shipping.shipmentMethod
		shipping
	
	cartSubTotal : ->
		subtotal = 0
		if @?.items
			subtotal += (items.quantity * items.variants.price) for items in @.items
		subtotal = subtotal.toFixed(2)
		subtotal
	
	cartTaxes : ->
		###
		# TODO: lookup cart taxes, and apply rules here
		###
		"0.00"
	
	cartDiscounts : ->
		###
		# TODO: lookup discounts, and apply rules here
		###
		"0.00"
	
	cartTotal : ->
		subtotal = 0
		if @?.items
			subtotal += (items.quantity * items.variants.price) for items in @.items
		
		shipping = 0
		if @?.shipping?.shipmentMethod?.rate
			shipping = @?.shipping?.shipmentMethod?.rate
		else if @?.shipping?.shipmentMethod.length > 0
			shipping += shippingMethod.rate \
			for shippingMethod in @.shipping.shipmentMethod
			
		shipping = parseFloat shipping
		subtotal = (subtotal + shipping) unless isNaN(shipping)
		total = subtotal.toFixed(2)


OfferMarket.Collections.Cart = Cart = @Cart = new Mongo.Collection "Cart",
	transform: (cart) ->
		newInstance = Object.create(OfferMarket.Helpers.cartTransform)

		_.extend newInstance, cart


OfferMarket.Collections.Cart.attachSchema OfferMarket.Schemas.Cart

# Accounts
OfferMarket.Collections.Accounts = Accounts = @Accounts = new Mongo.Collection "Accounts"

OfferMarket.Collections.Accounts.attachSchema OfferMarket.Schemas.Accounts

# Orders
OfferMarket.Collections.Orders = Orders = @Orders =
	new Mongo.Collection "Orders",
		transform: (order) ->
			order.itemCount = ->
				count = 0
				((count += items.quantity) for items in order.items) if order?.items
				count
			order

OfferMarket.Collections.Orders.attachSchema([
	OfferMarket.Schemas.Cart,
	OfferMarket.Schemas.Order,
	OfferMarket.Schemas.OrderItems])

# Packages
OfferMarket.Collections.Packages = new Mongo.Collection "Packages"
OfferMarket.Collections.Packages.attachSchema(
	OfferMarket.Schemas.PackageConfig)

# Products
OfferMarket.Collections.Products =
	Products = @Products = new Mongo.Collection "Products"
	
OfferMarket.Collections.Products.attachSchema(
	OfferMarket.Schemas.Product)

# Shipping
OfferMarket.Collections.Shipping = new Mongo.Collection "Shipping"
OfferMarket.Collections.Shipping.attachSchema(
	OfferMarket.Schemas.Shipping)

# Taxes
OfferMarket.Collections.Taxes = new Mongo.Collection "Taxes"
OfferMarket.Collections.Taxes.attachSchema(OfferMarket.Schemas.Taxes)

# Discounts
OfferMarket.Collections.Discounts = new Mongo.Collection "Discounts"
OfferMarket.Collections.Discounts.attachSchema(OfferMarket.Schemas.Discounts)

# Shops
OfferMarket.Collections.Shops = Shops = @Shops = new Mongo.Collection "Shops",
	transform: (shop) ->
		for index, member of shop.members
			member.index = index
			member.user = Meteor.users.findOne member.userId
		shop

OfferMarket.Collections.Shops.attachSchema(OfferMarket.Schemas.Shop)

# Tags
OfferMarket.Collections.Tags = Tags = @Tags = new Mongo.Collection "Tags"
OfferMarket.Collections.Tags.attachSchema OfferMarket.Schemas.Tag

# Tags
OfferMarket.Collections.Translations = new Mongo.Collection "Translations"
OfferMarket.Collections.Translations.attachSchema(
	OfferMarket.Schemas.Translation)


OfferMarket.Collections.Pages = new Mongo.Collection('pages')

Meteor.publish 'pages', ->

		fields = 
				title: 1
				path: 1
				template: 1
				description: 1
				order: 1
				previewVideo: 1

		user = Meteor.users.findOne @userId
		isSubscribed = OfferMarket.Services.Account.isSubscribed(user)

		if @userId and isSubscribed
				fields.premiumContent = 1
				fields.premiumVideo = 1

		OfferMarket.Collections.Pages.find {}, fields: fields

OfferMarket.Collections.Audit = new Mongo.Collection('audit')