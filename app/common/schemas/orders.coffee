###
# Payments Schema
###
OfferMarket.Schemas.PaymentMethod = new SimpleSchema
	processor:
		type: String
	storedCard:
		type: String
		optional: true
	method:
		type: String
		optional: true
	transactionId:
		type: String
	status:
		type: String
		allowedValues: ["created", "approved", "failed", "cancelled", "expired", "pending", "voided", "settled"]
	mode:
		type: String
		allowedValues: ["authorize", 'capture', 'refund', 'void']
	createdAt:
		type: Date
		autoValue: ->
			if @isInsert
				return new Date
			else if @isUpsert
				return $setOnInsert: new Date
		denyUpdate: true
	updatedAt:
		type: Date
		optional :true
	authorization:
		type: String
		optional: true
	amount:
		type: Number
		decimal: true
	transactions:
		type: [Object]
		optional: true
		blackbox: true

OfferMarket.Schemas.Invoice = new SimpleSchema
	transaction:
		type: String
		optional: true
	shipping:
		type: Number
		decimal: true
		optional: true
	taxes:
		type: Number
		decimal: true
		optional: true
	subtotal:
		type: Number
		decimal: true
	discounts:
		type: Number
		decimal: true
		optional: true
	total:
		type: Number
		decimal: true


OfferMarket.Schemas.Payment = new SimpleSchema
	address:
		type: OfferMarket.Schemas.Address
		optional: true
	paymentMethod:
		type: [OfferMarket.Schemas.PaymentMethod]
		optional: true
	invoices:
		type: [OfferMarket.Schemas.Invoice]
		optional: true


###
# Orders
###
OfferMarket.Schemas.Document = new SimpleSchema
	docId:
		type: String
	docType:
		type: String
		optional: true

OfferMarket.Schemas.History = new SimpleSchema
	event:
		type: String
	userId:
		type: String
	updatedAt:
		type: Date

OfferMarket.Schemas.Notes = new SimpleSchema
	content:
		type: String
	userId:
		type: String
	updatedAt:
		type: Date


###
# OfferMarket.Schemas.OrderItems
# merges with OfferMarket.Schemas.Cart, OfferMarket.Schemas.Order]
# to create Orders collection
###
OfferMarket.Schemas.OrderItems = new SimpleSchema
	additionalField:
		type: String
		optional: true
	status:
		type: String
	history:
		type: [OfferMarket.Schemas.History]
		optional: true
	documents:
		type: [OfferMarket.Schemas.Document]
		optional: true

OfferMarket.Schemas.Order = new SimpleSchema
	cartId:
		type: String
		optional: true
	history:
		type: [OfferMarket.Schemas.History]
		optional: true
	documents:
		type: [OfferMarket.Schemas.Document]
		optional: true
	notes:
		type: [OfferMarket.Schemas.Notes]
		optional: true