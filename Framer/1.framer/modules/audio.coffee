# The MIT License (MIT)
#
# Copyright (c) 2015 Benjamin den Boer
#
#     https://github.com/benjaminnathan/Framer-AudioPlayer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class exports.AudioPlayer extends Layer

	constructor: (options={}) ->
		options.backgroundColor ?= "transparent"

		# Define player
		@player = document.createElement("audio")
		@player.setAttribute("webkit-playsinline", "true")
		@player.setAttribute("preload", "auto")
		@player.style.width = "100%"
		@player.style.height = "100%"

		@player.on = @player.addEventListener
		@player.off = @player.removeEventListener

		super options

		# Define basic controls
		@controls = new Layer
			backgroundColor: "transparent"
			width: 80, height: 80, superLayer: @
			name: "controls"

		@controls.showPlay = -> @image = "images/play.png"
		@controls.showPause = -> @image = "images/pause.png"
		@controls.showPlay()
		@controls.center()

		@timeStyle = { "font-size": "20px", "color": "#000" }

		# On click
		@on Events.Click, ->
			currentTime = Math.round(@player.currentTime)
			duration = Math.round(@player.duration)

			if @player.paused
				@player.play()
				@controls.showPause()

				if currentTime is duration
					@player.currentTime = 0
					@player.play()
			else
				@player.pause()
				@controls.showPlay()

		# On end, switch to play button
		@player.onplaying = => @controls.showPause()
		@player.onended = => @controls.showPlay()

		# Utils
		@player.formatTime = ->
			sec = Math.floor(@currentTime)
			min = Math.floor(sec / 60)
			sec = Math.floor(sec % 60)
			sec = if sec >= 10 then sec else '0' + sec
			return "#{min}:#{sec}"

		@player.formatTimeLeft = ->
			sec = Math.floor(@duration) - Math.floor(@currentTime)
			min = Math.floor(sec / 60)
			sec = Math.floor(sec % 60)
			sec = if sec >= 10 then sec else '0' + sec
			return "#{min}:#{sec}"

		@audio = options.audio
		@_element.appendChild(@player)

	@define "audio",
		get: -> @player.src
		set: (audio) ->
			@player.src = audio
			if @player.canPlayType("audio/mp3") == ""
				throw Error "No supported audio file included."

	@define "showProgress",
		get: -> @_showProgress
		set: (showProgress) -> @setProgress(showProgress, false)

	@define "showVolume",
		get: -> @_showVolume
		set: (showVolume) -> @setVolume(showVolume, false)

	@define "showTime",
		get: -> @_showTime
		set: (showTime) -> @getTime(showTime, false)

	@define "showTimeLeft",
		get: -> @_showTimeLeft
		set: (showTimeLeft) -> @getTimeLeft(showTimeLeft, false)

	# Checks a property, returns "true" or "false"
	_checkBoolean: (property) ->
		if _.isString(property)
			if property.toLowerCase() in ["1", "true"]
				property = true
			else if property.toLowerCase() in ["0", "false"]
				property = false
			else
				return
		if not _.isBoolean(property) then return

	getTime: (showTime) ->
		@_checkBoolean(showTime)
		@_showTime = showTime

		if showTime is true
			@time = new Layer
				backgroundColor: "transparent"
				name: "currentTime"

			@time.style = @timeStyle
			@time.html = "0:00"

			@player.ontimeupdate = =>
				@time.html = @player.formatTime()

	getTimeLeft: (showTimeLeft) =>
		@_checkBoolean(showTimeLeft)
		@_showTimeLeft = showTimeLeft

		if showTimeLeft is true
			@timeLeft = new Layer
				backgroundColor: "transparent"
				name: "timeLeft"

			@timeLeft.style = @timeStyle

			# Set timeLeft
			@timeLeft.html = "-0:00"
			@player.on "loadedmetadata", =>
				@timeLeft.html = "-" + @player.formatTimeLeft()

			@player.ontimeupdate = =>
				@timeLeft.html = "-" + @player.formatTimeLeft()

	setProgress: (showProgress) ->
		@_checkBoolean(showProgress)

		# Set argument (showProgress is either true or false)
		@_showProgress = showProgress

		if @_showProgress is true

			# Create Progress Bar + Defaults
			@progressBar = new SliderComponent
				width: 200, height: 6, backgroundColor: "#eee"
				knobSize: 20, value: 0, min: 0

			@player.oncanplay = => @progressBar.max = Math.round(@player.duration)
			@progressBar.knob.draggable.momentum = false

			# Check if the player was playing
			wasPlaying = isMoving = false
			unless @player.paused then wasPlaying = true

			@progressBar.on "change:value", =>
				@player.currentTime = @progressBar.value

				if @time and @timeLeft
					@time.html = @player.formatTime()
					@timeLeft.html = "-" + @player.formatTimeLeft()

			@progressBar.knob.on Events.DragMove, => isMoving = true

			@progressBar.knob.on Events.DragEnd, (event) =>
				currentTime = Math.round(@player.currentTime)
				duration = Math.round(@player.duration)

				if wasPlaying and currentTime isnt duration
					@player.play()
					@controls.showPause()

				if currentTime is duration
					@player.pause()
					@controls.showPlay()

				return isMoving = false

			# Update Progress
			@player.ontimeupdate = =>
				unless isMoving
					@progressBar.knob.midX = @progressBar.pointForValue(@player.currentTime)
					@progressBar.knob.draggable.isMoving = false

				if @time and @timeLeft
					@time.html = @player.formatTime()
					@timeLeft.html = "-" + @player.formatTimeLeft()

	setVolume: (showVolume) ->
		@_checkBoolean(showVolume)

		# Set default to 75%
		@player.volume ?= 0.75

		@volumeBar = new SliderComponent
			width: 200, height: 6
			backgroundColor: "#eee"
			knobSize: 20
			min: 0, max: 1
			value: @player.volume

		@volumeBar.knob.draggable.momentum = false

		@volumeBar.on "change:width", =>
			@volumeBar.value = @player.volume

		@volumeBar.on "change:value", =>
			@player.volume = @volumeBar.value
