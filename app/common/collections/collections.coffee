
# Products
OfferMarket.Collections.Products =
	Products = @Products = new Mongo.Collection "Products"
	
OfferMarket.Collections.Products.attachSchema(
	OfferMarket.Schemas.Product)