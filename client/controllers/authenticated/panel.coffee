###
  Controller: Panel
  Template: /client/includes/_panel.html
###

# Events
Template.panel.events(
  'click .js-logout': (e,t) ->
    Meteor.logout((error)->
      alert error.reason if error
    )
)
