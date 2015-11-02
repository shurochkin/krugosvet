
key = '1VEHW2b9vtRWgGURwDCPpKaL5Zm5Lh8AiGXEwGMla7M8';
daysWeek = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье']

loadData = (key, sheet, callback) ->
  url = "http://spreadsheets.google.com/feeds/cells/" + key + "/" + sheet + "/public/basic?alt=json-in-script&callback=" + callback
  $('head').append("<script src='" +url+ "'/>")


parseData = (data, col) ->
	cells = (cell.content.$t for cell in data.feed.entry)
	i = 0
	r = 0
	row = []
	item = []
	for cell in cells
		row[i++] = cell
		unless i < col
			item[r++] = row
			row = []
			i = 0
	item.splice 1, item.length-1

setLessons = (result) ->
	data = parseData result, 9
	lessons = []
	for row in data
		lesson = {
			id: row[0]
			cat: row[1]
			title: row[2]
			age_start: row[3]
			age_end: row[4]
			included: row[5]
			have: row[6]
			time: row[7]
			people: row[8]
		}
		lessons.push lesson
	localStorage.lessons = JSON.stringify lessons
window.setLessons = setLessons

setEvents = (result) ->
	data = parseData result, 3
	events = []
	for row in data
		event = {
			id: row[0]
			day_week: row[1]
			time: row[2]
		}
		events.push event
	localStorage.events = JSON.stringify events
window.setEvents = setEvents

setCats = (result) ->
	data = parseData result, 2
	cats = []
	for row in data
		cat = {
			cat: row[0]
			title: row[1]
		}
		cats.push cat
	localStorage.cats = JSON.stringify cats
window.setCats = setCats


drawSchedule = ->
	events = JSON.parse localStorage.events
	lessons = JSON.parse localStorage.lessons
	cats = JSON.parse localStorage.cats
	cls = _.groupBy(cats, 'cat')
	container = $('#schedule-table .tbody')
	container.html('')
	times = _.groupBy(_.sortBy(events, 'time'), 'time')
	#console.log times
	for time, obj of times
		do (time, obj) ->
			tr = $('<div>').addClass('tr')
			tdf = $('<div>').addClass('td').text(time)
			tr.append(tdf)
			#console.log time
			for day in [1..6]
				td = $('<div>').addClass('td')
				#console.log day
				res = _.result(_.groupBy(obj, 'day_week'), day)
				if res?.length > 1 then td.addClass('dbl')
				if res? then for evnt in res
					id = _.result(evnt, 'id')
					lesson = _.result(_.groupBy(lessons, 'id'), id)
					less = $('<div>').addClass(_.map(lesson, 'cat').join('') + ' lesson').attr('data-id', id).text(_.map(lesson, 'title'))
					td.append(less)
				tr.append(td)
			container.append( tr )

	$('#schedule-table .tbody .lesson').click ->
		id = $(this).attr('data-id')
		obj = $('#details .desc')
		form = $('#details form')
		form.addClass('hide')
		obj.removeClass('hide')
		events = JSON.parse localStorage.events
		lessons = JSON.parse localStorage.lessons
		cats = JSON.parse localStorage.cats
		lesson = _.result(_.groupBy(lessons, 'id'), id)
		console.log  lesson
		$('.cat', obj).html('<span class="'+_.map(lesson, 'cat')+'">'+_.map(_.result(_.groupBy(cats, 'cat'), _.map(lesson, 'cat')), 'title')+'</span>')
		$('h3', obj).text(_.map(lesson, 'title'))
		$('h3 .tarif', form).text(_.map(lesson, 'title'))
		$('input[name="tarif"]', form).val(_.map(lesson, 'title'))
		$('.age .start', obj).text(_.map(lesson, 'age_start'))
		$('.age .end', obj).text(_.map(lesson, 'age_end'))
		incl = for idx, item of _.map(lesson, 'included').toString().split("\n")
			"<li>#{item}</li>"
		$('ul.included', obj).html(incl.join(''))
		have = for idx, item of _.map(lesson, 'have').toString().split("\n")
			"<li>#{item}</li>"
		$('ul.have', obj).html(have.join(''))
		sched = for day, item of _.groupBy(_.sortBy(_.result(_.groupBy(events, 'id'), id), 'day_week'), 'day_week')
			d = daysWeek[day-1]
			t = _.map(item, 'time').toString()
			"<span>#{d} #{t}</span>"
		$('.schedule', obj).html(sched.join(''))
		$('.time', obj).text('продолжительность: ' + _.map(lesson, 'time') + ' мин')
		$('.people', obj).text('группа: ' + _.map(lesson, 'people') + ' человек')
		$('.submit button', obj).click ->
			obj.addClass('hide')
			form.removeClass('hide')
			$.fancybox.update()
			false
		$.fancybox.open 
			href: '#details'
			minWidth: 550
			maxWidth: 550
		false

indexSchedule = ->
	events = JSON.parse localStorage.events
	lessons = JSON.parse localStorage.lessons
	cats = JSON.parse localStorage.cats
	cls = _.groupBy(cats, 'cat')
	
	container = $('#today .schedule ul')
	container.html('')
	now = new Date
	dayOfWeek = now.getDay()
	#dayOfWeek = 2
	times = _.groupBy(_.sortBy(events, 'time'), 'day_week')
	today = _.result(times, dayOfWeek)
	unless today 
		container.append( '<li>Выходной день</li>' )
	else 
		for index, obj of today
			do (index, obj) ->
				li = $('<li>')
				time = $('<time>').html(_.result(obj, 'time'))
				lesson = _.result(_.groupBy(lessons, 'id'), _.result(obj, 'id'))
				li.append(time).append(_.map(lesson, 'title'))
				container.append(li)


priceParams = 'sel '

choicePrice = (frm, el) ->
	e = $(el)

	if e.attr('name') == 'q1' and e.attr('value') == '1'
		priceParams += 'nurs '
	
	if e.attr('name') == 'q2' and e.attr('value') == '1'
		priceParams += 'half '
		priceParams += 'five '
		do showPrice
		return

	if e.attr('name') == 'q3'
		priceParams += 'full '
		priceParams += switch e.attr('value')
			when '1' then 'one '
			when '2' then 'three '
			when '3' then 'five '
	if frm.getCurrentSlide() < 2 then frm.goToNextSlide() else do showPrice
		

showPrice = ->
	#console.log priceParams
	widget = $('#price-form').find('.widget')
	item = $('#price-form').find('.item')
	widget.addClass('hide')
	item.removeClass('sel half full five three one nurs').addClass(priceParams).removeClass('hide')


parallaxScroll = ->
	scrolled = $(window).scrollTop()
	$('#parallax-bg1').css('top',(0-(scrolled*.8))+'px')
	$('#parallax-bg2').css('top',(0-(scrolled*.65))+'px')
	$('#parallax-bg3').css('top',(0-(scrolled*.90))+'px')
	$('#parallax-bg4').css('top',(0-(scrolled*.80))+'px')
	$('#parallax-bg5').css('top',(0-(scrolled*1.3))+'px')
	$('#parallax-bg7').css('top',(0-(scrolled*.75))+'px')
	$('#parallax-bg6').css('top',(0-(scrolled*1))+'px').css('left',(3000-(scrolled*.7))+'px')
	return

$.extend $.fancybox.defaults, 
	padding: 30
	content: 'html'

sendMail = (subject, message) ->
	xmlhttp = if (window.XMLHttpRequest) then new XMLHttpRequest() else new ActiveXObject("Microsoft.XMLHTTP")
	xmlhttp.open('POST', 'https://mandrillapp.com/api/1.0/messages/send.json')
	xmlhttp.setRequestHeader('Content-Type', 'application/json;charset=UTF-8')
	xmlhttp.onreadystatechange = () ->
	    if (xmlhttp.readyState == 4) 
	        if(xmlhttp.status == 200)
	        	alert('Сообщение успешно отправлено!')
	        	$.fancybox.close()
	        else if(xmlhttp.status == 500) then alert('Check apikey')
	        else alert('Request error')
	    return false
	
	xmlhttp.send JSON.stringify
		'key': 'd7GpUjdE1F05IqRziH757Q',
		'message': 
			'from_email': 'kids@krugosvet.spb.ru',
			'to': [{'email': 'krugosvet.spb@yandex.ru', 'type': 'to'}],
			'autotext': 'true',
			'subject': subject,
			'html': message
	    


$(document).ready ->

	$(window).bind 'scroll', ->
		if $('body').hasClass('panel-opened') 
			$('body').removeClass('panel-opened')
			$('#contact').text('Контакты').removeClass('active')
		do parallaxScroll
		return

	$('#contact').click ->
		$('body').toggleClass('panel-opened')
		if $('body').hasClass('panel-opened') 
			$('#contact').text('Закрыть').prepend('<i class="fa fa-times"></i> ').addClass('active')
		else
			$('#contact').text('Контакты').removeClass('active')
		return false
		

	$('#interior .slider').bxSlider
		wrapperClass: 'slider-wrapper'
		pagerSelector: '#interior .slider-pager'
		pagerType: 'short'
		prevSelector: '#interior .slider-prev'
		prevText: '<i class="fa fa-chevron-circle-left"></i>'
		nextSelector: '#interior .slider-next'
		nextText: '<i class="fa fa-chevron-circle-right"></i>'

	teachers = $('#teachers-slider .slider').bxSlider
		mode: 'fade'
		infiniteLoop: false
		hideControlOnEnd: true
		wrapperClass: 'slider-wrapper'
		pagerSelector: '#teachers-slider .slider-pager'
		pager: false
		prevSelector: '#teachers-slider .slider-prev'
		prevText: '<i class="fa fa-chevron-circle-left"></i>'
		nextSelector: '#teachers-slider .slider-next'
		nextText: '<i class="fa fa-chevron-circle-right"></i>'

	form = $('#price-form .slider').bxSlider
		infiniteLoop: false
		hideControlOnEnd: true
		wrapperClass: 'slider-wrapper'
		pagerSelector: '#price-form .slider-pager'
		pagerType: 'short'
		prevSelector: '#price-form .slider-prev'
		prevText: '<i class="fa fa-chevron-circle-left"></i>'
		nextSelector: '#price-form .slider-next'
		nextText: '<i class="fa fa-chevron-circle-right"></i>'

	$('#price-form input').click ->
		$(this).parents('li').find('label').removeClass('checked')
		$(this).parents('label').addClass('checked')
		choicePrice form, this
	
	$('#price-wizard .price-list a').click ->
		widget = $('#price-form').find('.widget')
		item = $('#price-form').find('.item')
		item.removeClass('sel half full five three one nurs').addClass('hide')
		widget.removeClass('hide')
		priceParams = 'sel '
		$('#price-form .checked').removeClass('checked')
		form.goToSlide(0)
		return false

	$('#price-wizard li.show').click ->
		priceParams = $(this).data('param')
		do showPrice

	$('#teachers .item').click ->
		teachers.goToSlide( $(this).index() )
		$('#teachers-slider').show()
		return false
	
	$('#teachers-slider .close a').click ->
		$('#teachers-slider').hide()
		return false

	$('#plane a').fancybox {
		maxWidth: 640
		maxHeight: 360
		href: '#video'
	}

	$('#programm .schedule a').fancybox {
		maxWidth: 640
		href: '#schedule'
	}
	$('.price-special').fancybox {
		minWidth: 550
		href: '#price-special'
	}
	$('.price-excursion').fancybox {
		minWidth: 550
		href: '#price-excursion'
	}
	$('.price-order').fancybox {
		minWidth: 550
		href: '#price-order'
	}
	$('form').submit ->
		form = $(this)
		id = $(this).parent().attr('id')
		data = {}
		subject = 'Письмо с сайта: '
		data.email = form.find('input[name="email"]').val()
		data.phone = form.find('input[name="phone"]').val()
		data.time = form.find('input[name="time"]').val()
		data.service = form.find('input[name="service"]').val()
		data.director = form.find('input[name="director"]').val()
		data.parent = form.find('input[name="parent_firstname"]').val() + ' ' +form.find('input[name="parent_lastname"]').val()
		data.kinder = form.find('input[name="kinder_firstname"]').val() + ' ' +form.find('input[name="kinder_lastname"]').val()
		data.kinder_age = form.find('input[name="age"]').val()
		
		if id is 'details'
			data.tarif = form.find('input[name="tarif"]').val()
		else 
			cl = $('#price-wizard .item').attr('class').split(' ')
			data.tarif = (if _.indexOf(cl, 'full') > 0 then 'Полный' else if _.indexOf(cl, 'half') > 0 then 'Неполный') + ' день, '
			data.tarif += if _.indexOf(cl, 'five') > 0  then '5 дней в неделю' else if _.indexOf(cl, 'three') > 0 then '3 дня в неделю' else if _.indexOf(cl, 'one') >0 then 'Разовое посещение'

		message = switch
			when id is 'price-special' 		then "<p>email: #{data.email}</p><p>телефон: #{data.phone}</p>"
			when id is 'price-excursion' 	then "<p>Родитель: #{data.parent} (тел: #{data.phone})</p><p>Ребенок: #{data.kinder} (возраст: #{data.kinder_age})</p><p>Время посещения: #{data.time}</p><p>Интересует: #{data.service}</p><p>Общение с директором: #{data.director}</p>"
			when id is 'price-order' 		then "<p>Родитель: #{data.parent} (тел: #{data.phone})</p><p>Ребенок: #{data.kinder} (возраст: #{data.kinder_age})</p><p>Тариф: #{data.tarif}</p>"
			when id is 'details'	 		then "<p>Родитель: #{data.parent} (тел: #{data.phone})</p><p>Ребенок: #{data.kinder} (возраст: #{data.kinder_age})</p><p>Занятие: #{data.tarif}</p>"
			
		subject = switch
			when id is 'price-special' 		then 'Спец. предложение'
			when id is 'price-excursion'	then 'Экскурсия'
			when id is 'price-order' 		then 'Запись в детсад'
			when id is 'details' 			then 'Запись в клуб'

		$.fancybox.showLoading()
		sendMail subject, message
		false

	if clubpage?
		loadData(key, 1, 'setLessons')
		loadData(key, 2, 'setEvents')
		loadData(key, 3, 'setCats')
		do drawSchedule

	if homepage?
		loadData(key, 1, 'setLessons')
		loadData(key, 2, 'setEvents')
		do indexSchedule


