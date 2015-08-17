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
  // Domain specific logic.
  Services: {},
  Subscriptions: {},
  API: {}
};

var global = this;
global.OfferMarket = OfferMarket;
