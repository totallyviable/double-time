{AudioPlayer} = require "audio"

Framer.Device.background.backgroundColor = "#303138"

master = new Layer
	x: 0
	y: 0
	width: Screen.width
	height: Screen.height
	backgroundColor: "transparent"

top = new Layer
	parent: master
	x: master.x
	y: master.y
	width: master.width
	height: master.height / 2
	backgroundColor: "transparent"

bottom = new Layer
	parent: master
	x: master.x
	y: master.height / 2
	width: master.width
	height: master.height / 2
	backgroundColor: "transparent"

topProgress = new Layer
	parent: top
	x: 0
	y: 0
	width: 0
	height: top.height
	backgroundColor: "#eb4300"

bottomProgress = new Layer
	parent: bottom
	x: 0
	y: 0
	width: 0
	height: bottom.height
	backgroundColor: "#1946bd"

topText = new Layer
	parent: top
	height: 100
	width: master.width
	backgroundColor: "transparent"
	html: "00:00:00"
	style:
		"text-align": "center"
		"font": "normal 100px Akkurat Std"
	
bottomText = new Layer
	parent: bottom
	height: 100
	width: master.width
	backgroundColor: "transparent"
	html: "00:00:00"
	style:
		"text-align": "center"
		"font": "normal 100px Akkurat Std"
	
topText.center()
bottomText.center()

timers = {
	top: {
		audio: new AudioPlayer audio: "audio/doubletime-timer-b.wav"
		textLayer: topText
		progressLayer: topProgress
		time: 5
		current_time: 0
	}
	
	bottom: {
		audio: new AudioPlayer audio: "audio/doubletime-timer-a.wav"
		textLayer: bottomText
		progressLayer: bottomProgress
		time: 3
		current_time: 0
	}
}

ff_seconds = (bar) ->
	num = 0
	
	ff_interval = Utils.interval 0.024, ->
		num += Math.ceil(timers[bar].time / 24)
		update_time_text(bar, num)
		
		if num >= timers[bar].time
			clearInterval(ff_interval)
	

format_seconds = (seconds) ->
	hours = Math.floor(seconds / 3600)
	seconds %= 3600
	minutes = Math.floor(seconds / 60)
	seconds = seconds % 60
	
	if hours < 10
		hours = "0" + hours
	
	if minutes < 10
		minutes = "0" + minutes
	
	if seconds < 10
		seconds = "0" + seconds
	
	return [hours, minutes, seconds]

update_time_text = (bar, time = null) ->
	if (time == null) 
		time = timers[bar].current_time
	
	value = format_seconds(time).join("<span style='vertical-align:7px'>:</span>")
	
	timers[bar].textLayer.html = value

animate_bar = (bar, callback) ->
	barLayer = timers[bar].progressLayer
	
	timers[bar].current_time = timers[bar].time;
	update_time_text(bar, timers[bar].time)
	
	barLayer.props =
		opacity: 1
		width: 0
	
	timers[bar].textLayer.animate
			time: 0.3
			curve: "linear"
			properties:
				color: "#fff"
	
	barAnimation = barLayer.animate
		time: timers[bar].time
		curve: "linear"
		properties:
			width: master.width
	
	time_interval = Utils.interval 1, ->
		timers[bar].current_time--
		update_time_text(bar)
	
	barAnimation.on Events.AnimationEnd, ->
		timers[bar].audio.player.play()
		
		barLayer.animate
			time: 0.3
			curve: "linear"
			properties:
				opacity: 0
		
		clearInterval(time_interval)

		ff_seconds(bar)
		
		timers[bar].textLayer.animate
			time: 0.3
			curve: "linear"
			properties:
				color: "#79756a"
		
		callback()

run = (bar) ->
	if bar == "top"
		animate_bar bar, ->
			run("bottom")
		
	else if bar == "bottom"
		animate_bar bar, ->
			run("top")

init = ->
	update_time_text("top", timers["top"].time)
	update_time_text("bottom", timers["bottom"].time)
	
	run "top"

init()