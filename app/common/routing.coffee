###
#  Global Route Configuration
#  Extend/override in reaction/client/routing.coffee
###
Router.configure
	notFoundTemplate: "notFound"
	loadingTemplate: "loading"
	onBeforeAction: ->
		if Meteor.isClient
			@render "loading"
			Alerts.removeSeen()
			$(document).trigger('closeAllPopovers')			
		@next()


# general controller
ShopController = RouteController.extend
	onAfterAction: ->
		OfferMarket.MetaData.refresh(@route, @params)
	layoutTemplate: "coreLayout"
	yieldTemplates:
		layoutHeader:
			to: "layoutHeader"
		layoutFooter:
			to: "layoutFooter"
		dashboard:
			to: "dashboard"

# local ShopController
@ShopController = ShopController


###
# General Route Declarations
###
Router.map ->
	@route "unauthorized",
		template: "unauthorized"
		name: "unauthorized"
		yieldTemplates:
			checkoutHeader:
				to: "layoutHeader"

	# default index route
	@route "index",
		controller: ShopController
		path: "/"
		name: "index"
		template: "products"
		waitOn: ->
			@subscribe "Products"


	# product view / edit page
	@route 'product',
		controller: ShopController
		path: 'product/:_id/:variant?'
		template: 'productDetail'
		subscriptions: ->
			@subscribe 'Product', @params._id
		onBeforeAction: ->
			variant = @params.variant || @params.query.variant
			setProduct @params._id, variant
			@next()
		data: ->
			# TODO: OfferMarket.hasAdminAccess(@url)
			product = selectedProduct()
			if @ready() and product
				unless product.isVisible
					unless OfferMarket.hasPermission('createProduct')
						@render 'unauthorized'
				return product
			if @ready() and !product
				@render 'notFound'