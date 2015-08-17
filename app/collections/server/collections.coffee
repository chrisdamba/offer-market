OfferMarket.Collections.Pages = new Mongo.Collection('pages')

Meteor.publish 'pages', ->

	fields = 
		title: 1
		path: 1
		template: 1
		description: 1
		order: 1
		previewVideo: 1

	user = Meteor.users.findOne @userId
	isSubscribed = OfferMarket.Services.Account.isSubscribed(user)

	if @userId and isSubscribed
		fields.premiumContent = 1
		fields.premiumVideo = 1

	OfferMarket.Collections.Pages.find {}, fields: fields

OfferMarket.Collections.Audit = new Mongo.Collection('audit')