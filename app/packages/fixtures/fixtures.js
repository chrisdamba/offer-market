(function () {

  'use strict';

  Meteor.methods({

    'fixtures/seedData': OfferMarket.Utils.seedData,

    'fixtures/reset': function (noResetUsers) {

      if (!noResetUsers) {
        Meteor.users.remove({});
      }

      OfferMarket.Collections.Audit.remove({});
      OfferMarket.Collections.Pages.remove({});
    },

    'fixtures/page/create': function (pages) {

      // convert page to an array just in case it's a single page
      pages = [].concat(pages);

      // then create all pages
      for (var i = 0; i < pages.length; i++) {
        OfferMarket.Collections.Pages.insert(pages[i]);
      }
    },

    'fixtures/findAudit': function (query) {
      return OfferMarket.Collections.Audit.find(query).fetch();
    },

    'fixtures/getSettings': function () {
      return Meteor.settings;
    },    

    'fixtures/createAccount': function (user) {
      return Accounts.createUser(user);
    }

  });

})();
