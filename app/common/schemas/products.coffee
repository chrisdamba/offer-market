###
# Products
###


OfferMarket.Schemas.Product = new SimpleSchema
	_id:
		type: String
		optional: true
	cloneId:
		type: String
		optional: true
	shopId:
		type: String
		#autoValue: OfferMarket.shopIdAutoValue
		index: 1
	title:
		type: String
	pageTitle:
		type: String
		optional: true
	description:
		type: String
		optional: true
	productType:
		type: String
	vendor:
		type: String
		optional: true
	requiresShipping:
		label: "Require a shipping address"
		type: Boolean
		defaultValue: true
		optional: true
	hashtags:
		type: [String]
		optional: true
		index: 1
	# TODO: move social messsages to metafields
	twitterMsg:
		type: String
		optional: true
		max: 140
	facebookMsg:
		type: String
		optional: true
		max: 255
	googleplusMsg:
		type: String
		optional: true
		max: 255
	pinterestMsg:
		type: String
		optional: true
		max: 255
	metaDescription:
		type: String
		optional: true
	handle:
		type: String
		optional: true
		index: 1
	isVisible:
		type: Boolean
		index: 1
	publishedAt:
		type: Date
		optional: true
	publishedScope:
		type: String
		optional: true
	templateSuffix:
		type: String
		optional: true
	createdAt:
		type: Date
		autoValue: ->
			if @isInsert
				return new Date
			else if @isUpsert
				return $setOnInsert: new Date
		# denyUpdate: true
	updatedAt:
		type: Date
		autoValue: ->
			if @isUpdate
				return $set: new Date
			else if @isUpsert
				return $setOnInsert: new Date
		optional: true
