/**
 * This is the only file where globals should be declared.
 * We do this, so we can have all other files in strict mode.
 */

/* globals OfferMarket: true */

OfferMarket = {
	
	Constants: {},
	
	// Small reusable utilities
	Utils: {},
	
	// Meteor Mongo Collections
	Collections: {},
	
	// Meteor Mongo SimpleSchemas
	Schemas: {},

	// Domain specific logic.
	Services: {},
	
	Subscriptions: {},
	
	API: {},

	Helpers: {},

	MetaData: {},

	Locale: {},
	
	Events: {}

};


if (Meteor.isClient) {
	OfferMarket.Alerts = {};
	OfferMarket.Subscriptions = {};
}

// convenience
Alerts = OfferMarket.Alerts;
Schemas = OfferMarket.Schemas;

// not exported to client (private)
OfferMarketRegistry = {};
OfferMarketRegistry.Packages = {};


var global = this;
global.OfferMarket = OfferMarket;
global.OfferMarketRegistry = OfferMarketRegistry;
