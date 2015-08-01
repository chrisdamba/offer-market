myApp = new Framework7(
	animateNavBackIcon: true
	# Enable templates auto precompilation
	precompileTemplates: true
	# Enabled pages rendering using Template7
	swipeBackPage: true
	pushState: true
	template7Pages: true
)

# Export selectors engine
$$ = Dom7

# Add main View
mainView = myApp.addView('.view-main', 
	# Enable dynamic Navbar
	dynamicNavbar: false	
)
###
	Controller: Index
	Template: /client/views/public/index.html
###

# Events
Template.index.events(
	'click .btn-facebook': ->
		Meteor.loginWithFacebook(
			requestPermissions: ['email']
		, (error)->
			console.log error.reason if error
		)

	'click .btn-github': ->
		Meteor.loginWithGithub(
			requestPermissions: ['email']
		, (error)->
			console.log error.reason if error
		)

	'click .btn-google': ->
		Meteor.loginWithGoogle(
			requestPermissions: ['email']
		, (error)->
			console.log error.reason if error
		)

	'click .btn-twitter': ->
		Meteor.loginWithTwitter((error)->
			console.log error.reason if error
		)
)

Template.index.onRendered(->
	mainSwiper = new Swiper('.swiper-container',
	    speed: 400
	    spaceBetween: 100    
	)
)