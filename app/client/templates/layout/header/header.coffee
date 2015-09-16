Template.layoutHeader.events
	'click .navbar-accounts .dropdown-toggle': () ->
		setTimeout (->
			$("#login-email").focus()
		), 100

	# clears dashboard active links. needs a better approach.
	'click .header-tag, click .navbar-brand': () ->
		$('.dashboard-navbar-packages ul li').removeClass('active')


Template.layoutHeader.onRendered ->
	#Keep track of last scroll
	lastScroll = 0
	header = $('#header')
	headerfixed = $('#header-main-fixed')
	headerfixedbg = $('.header-bg')
	headerfixedtopbg = $('.top-header-bg')
	$(window).scroll ->
		#Sets the current scroll position
		st = $(this).scrollTop()
		#Determines up-or-down scrolling
		if st > lastScroll
			#Replace this with your function call for downward-scrolling
			if st > 50
				header.addClass 'header-top-fixed'
				header.find('.header-top-row').addClass 'dis-n'
				headerfixedbg.addClass 'header-bg-fixed'
				headerfixed.addClass 'header-main-fixed'
				headerfixedtopbg.addClass 'top-header-bg-fix'
		else
			#Replace this with your function call for upward-scrolling
			if st < 50
				header.removeClass 'header-top-fixed'
				header.find('.header-top-row').removeClass 'dis-n'
				headerfixed.removeClass 'header-main-fixed'
				headerfixedbg.removeClass 'header-bg-fixed'
				headerfixedtopbg.removeClass 'top-header-bg-fix'
				#headerfixed.addClass("header-main-fixed")
		#Updates scroll position
		lastScroll = st