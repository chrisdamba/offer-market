
# Products
OfferMarket.Collections.Products =
	Products = @Products = new Mongo.Collection "Products"
	
OfferMarket.Collections.Products.attachSchema(
	OfferMarket.Schemas.Product)

# Shops
OfferMarket.Collections.Shops = Shops = @Shops = new Mongo.Collection "Shops",
	transform: (shop) ->
		for index, member of shop.members
			member.index = index
			member.user = Meteor.users.findOne member.userId
		return shop

OfferMarket.Collections.Shops.attachSchema(OfferMarket.Schemas.Shop)

# Tags
OfferMarket.Collections.Tags = Tags = @Tags = new Mongo.Collection "Tags"
OfferMarket.Collections.Tags.attachSchema OfferMarket.Schemas.Tag