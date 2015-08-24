###
# methods typically used for checkout (shipping, taxes, etc)
###
Meteor.methods
	###
	# gets shipping rates and updates the users cart methods
	# TODO: add orderId argument/fallback
	###
	updateShipmentQuotes: (cartId) ->
		return unless cartId
		check cartId, String
		@unblock
		cart = OfferMarket.Collections.Cart.findOne(cartId)
		if cart
			# get fresh quotes
			# TODO: Apply rate filters here
			rates = Meteor.call "getShippingRates", cart

			# update users cart
			if rates.length > 0
				OfferMarket.Collections.Cart.update '_id': cartId,
					$set:
						'shipping.shipmentQuotes': rates

			# in the rates object
			OfferMarket.Events.debug rates


	###
	#  just gets rates, without updating anything
	###
	getShippingRates: (options) ->
		check options, Object
		# get shipping rates for each provider
		rates = []
		selector = {shopId:  OfferMarket.getShopId()}
		# if we have products from multiple shops in the cart.items we have to select the shipping options from those shops
		shops = []
		for product in options.items
			if product.shopId not in shops
				shops.push product.shopId

		# not sure if this is the correct condition since it will most certainly always be positive, if there are any products in the cart
		shops.push OfferMarket.getShopId() if OfferMarket.getShopId() not in shops
		if shops?.length > 0
			selector = {shopId: {$in: shops}}
		shipping = OfferMarket.Collections.Shipping.find(selector);
		# flat rate / table shipping rates
		shipping.forEach (shipping) ->
			## get all enabled rates
			for method, index in shipping.methods when method.enabled is true
				unless method.rate then method.rate = 0 #
				unless method.handling then method.handling = 0
				# rules

				# rate is shipping and handling
				rate = method.rate+method.handling
				rates.push carrier: shipping.provider.label, method: method, rate: rate, shopId: shipping.shopId

		# TODO:
		# wire in external shipping methods here, add to rates

		# in the rates object
		OfferMarket.Events.info "getShippingrates returning rates"
		OfferMarket.Events.debug "rates", rates
		rates

	###
	# add payment method
	###
	paymentMethod: (cartId, paymentMethod) ->
		check cartId, String
		check paymentMethod, Object
		Cart.update _id: cartId, {$addToSet:{"payment.paymentMethod":paymentMethod}}
