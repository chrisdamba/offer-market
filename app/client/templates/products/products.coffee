Template.products.events
	"click #productListView": ->
		$(".product-grid").hide()
		$(".product-list").show()

	"click #productGridView": ->
		$(".product-list").hide()
		$(".product-grid").show()

	"click .product-list-item": (event, template) ->
		Router.go "product",
			_id: @._id

Template.products.onRendered ->
	$("#nav-bestseller .next").click ->
		$("#owl-bestseller").trigger 'owl.next'
		
		
		$("#nav-bestseller .prev").click ->
			$("#owl-bestseller").trigger 'owl.prev'
		

		$("#owl-bestseller").owlCarousel
			items: 4
			itemsCustom: false
			itemsDesktop: [1199, 3]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false


		$("#nav-summer-sale .next").click ->
			$("#owl-summer-sale").trigger 'owl.next'
		
		$("#nav-summer-sale .prev").click ->
			$("#owl-summer-sale").trigger 'owl.prev'
		

		$("#owl-summer-sale").owlCarousel
			items: 3
			itemsCustom: false
			itemsDesktop: [1199, 2]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false


		$("#nav-child .next").click ->
			$("#owl-child").trigger 'owl.next'
		
		$("#nav-child .prev").click ->
			$("#owl-child").trigger 'owl.prev'


		$("#owl-child").owlCarousel
			items: 3
			itemsCustom: false
			itemsDesktop: [1199, 2]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false

		$("#nav-tabs .next").click ->
			$("#owl-new").trigger 'owl.next'
			$("#owl-featured").trigger 'owl.next'
		
		$("#nav-tabs .prev").click ->
			$("#owl-new").trigger 'owl.prev'
			$("#owl-featured").trigger 'owl.prev'


		$("#owl-new").owlCarousel
			items: 4
			itemsCustom: false
			itemsDesktop: [1199, 3]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false

		$("#owl-featured").owlCarousel
			items: 4
			itemsCustom: false
			itemsDesktop: [1199, 3]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false


		$("#nav-tabs2 .next").click ->
			$("#owl-new2").trigger 'owl.next'
			$("#owl-featured2").trigger 'owl.next'
		
		$("#nav-tabs2 .prev").click ->
			$("#owl-new2").trigger 'owl.prev'
			$("#owl-featured2").trigger 'owl.prev'
		
		$("#owl-new2").owlCarousel        
			items: 3
			itemsCustom: false
			itemsDesktop: [1199, 2]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false

		$("#owl-featured2").owlCarousel
			items: 3
			itemsCustom: false
			itemsDesktop: [1199, 2]
			itemsDesktopSmall: [980, 2]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: false
			stopOnHover: false
			navigation: false


		$("#owl-partners").owlCarousel
			items: 5
			itemsCustom: false
			itemsDesktop: [1199, 4]
			itemsDesktopSmall: [980, 3]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: true
			stopOnHover: false
			navigation: false

		$("#owl-home-slider").owlCarousel
			items: 1
			itemsCustom: false
			itemsDesktop: [1199, 1]
			itemsDesktopSmall: [980, 1]
			itemsTablet: [630, 1]
			itemsTabletSmall: false
			itemsMobile: [479, 1]
			singleItem: false
			itemsScaleUp: false
			responsive: true
			responsiveRefreshRate: 200
			responsiveBaseWidth: window
			autoPlay: true
			stopOnHover: false
			navigation: false

		$ ->
			$('.dropdown').hover (->
				$(this).addClass 'open'
				return
			), ->
				$(this).removeClass 'open'
			return
		return


		$holder = $("body").find ".holder"
		if (!$holder.length) 
			$("body").append "<div class='holder'></div>"

		$("div.holder").jPages
			containerID: "products"
			previous: ".feature-block a[data-role='prev']"
			next: ".feature-block a[data-role='next']"
			animation: "fadeInRight"
			perPage: 4

		$('.revolution').revolution
			delay: 9000
			startwidth: 1170
			startheight: 500
			hideThumbs: 10
			fullWidth: "on"
			fullScreen: "on"
			navigationType: "none"
			navigationArrows: "solo"
			navigationStyle: "round"
			navigationHAlign: "center"
			navigationVAlign: "bottom"
			navigationHOffset: 30
			navigationVOffset: 30
			soloArrowLeftHalign: "left"
			soloArrowLeftValign: "center"
			soloArrowLeftHOffset: 20
			soloArrowLeftVOffset: 0
			soloArrowRightHalign: "right"
			soloArrowRightValign: "center"
			soloArrowRightHOffset: 20
			soloArrowRightVOffset: 0
			touchenabled: "on"

		$('.tool_tip').tooltip()

		$(".colors li a").each ->
			$(this).css("background-color", "#" + $(this).attr("rel")).attr("href", "#" + $(this).attr("rel"))


		$('#product-zoom').elevateZoom
			zoomType: "inner"
			cursor: "crosshair"
			zoomWindowFadeIn: 500
			zoomWindowFadeOut: 750


		gallery = $('#gal1')
		gallery.find('a').hover ->
			smallImage = $(this).attr "data-image"
			largeImage = $(this).attr "data-zoom-image"
			ez = $('#product-zoom').data 'elevateZoom'

			ez.swaptheimage smallImage, largeImage



		date = new Date().getTime()
		new_date = new Date(date + 86400000)
		$(".time").countdown
			date: new_date
			yearsAndMonths: true
			leadingZero: true


		$('.ul-side-category li a').click ->
			sm = $(this).next()
			if sm.hasClass('sub-category')
				if sm.css('display') == 'none'
					$(this).next().slideDown()
				else
					$(this).next().slideUp()
					$(this).next().find('.sub-category').slideUp()
				false
			else
				true
