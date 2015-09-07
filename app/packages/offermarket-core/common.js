/**
 * This is the only file where globals should be declared.
 * We do this, so we can have all other files in strict mode.
 */

/* globals OfferMarket: true */

OfferMarket = {  
  
  API: {},

  Collections: {},
  
  Constants: {},  
  
  Events: {},

  Helpers: {},

  Locale: {},

  MetaData: {},

  Schemas: {},
  
  Services: {},
  
  Subscriptions: {},

  Utils: {}  
  
};

if (Meteor.isClient) {
	OfferMarket.Alerts = {};
	OfferMarket.Subscriptions = {};
}


// not exported to client (private)
OfferMarketRegistry = {};
OfferMarketRegistry.Packages = {};

// convenience
Alerts = OfferMarket.Alerts;
Schemas = OfferMarket.Schemas;

var global = this;
global.Alerts = Alerts;
global.OfferMarket = OfferMarket;
global.OfferMarketRegistry = OfferMarketRegistry;
global.Schemas = Schemas;