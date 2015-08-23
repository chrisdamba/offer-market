# Tax Rates
OfferMarket.Schemas.TaxRates = new SimpleSchema
	country:
		type: String
	county:
		type: String
		optional: true
	rate:
		type: Number

# Tax Methods
OfferMarket.Schemas.Taxes = new SimpleSchema
	shopId:
		type: String
		#autoValue: OfferMarket.shopIdAutoValue
		index: 1
	cartMethod:
		label: "Calculation Method"
		type: String
		allowedValues: ['unit','row','total']
	taxLocale:
		label: "Taxation Location"
		type: String
		allowedValues: ['shipping','billing', 'origination', 'destination']
	taxShipping:
		label: "Tax Shipping"
		type: Boolean,
		defaultValue: false
	taxIncluded:
		label: "Taxes included in product prices"
		type: Boolean
		defaultValue: false
	discountsIncluded:
		label: "Tax before discounts"
		type: Boolean
		defaultValue: false
	rates:
		label: "Tax Rate"
		type: [OfferMarket.Schemas.TaxRates]
