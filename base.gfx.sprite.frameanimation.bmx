SuperStrict
Import BRL.Map
Import BRL.Retro
Import "base.util.deltatimer.bmx"


Type TSpriteFrameAnimationCollection
	Field animations:TMap = CreateMap()
	Field currentAnimationName:string = ""


	'insert a TSpriteFrameAnimation with a certain Name
	Method Set(name:string, animation:TSpriteFrameAnimation)
		animations.insert(lower(name), animation)
		if not animations.contains("default") then setCurrent(name, 0)
	End Method


	'Set a new Animation
	'If it is a different animation name, the Animation will get reset (start from begin)
	Method SetCurrent(name:string, start:int = TRUE)
		name = lower(name)
		local reset:int = 1 - (currentAnimationName = name)
		currentAnimationName = name
		if reset then getCurrent().Reset()
		if start then getCurrent().Playback()
	End Method


	Method GetCurrent:TSpriteFrameAnimation()
		local obj:TSpriteFrameAnimation = TSpriteFrameAnimation(animations.ValueForKey(currentAnimationName))
		'load default if nothing was found
		if not obj then obj = TSpriteFrameAnimation(animations.ValueForKey("default"))
		return obj
	End Method


	Method Get:TSpriteFrameAnimation(name:string="default")
		local obj:TSpriteFrameAnimation = TSpriteFrameAnimation(animations.ValueForKey(name.toLower()))
		if not obj then obj = TSpriteFrameAnimation(animations.ValueForKey("default"))
		return obj
	End Method


	Method getCurrentAnimationName:string()
		return currentAnimationName
	End Method


	Method Update:int()
		GetCurrent().Update()
	End Method
End Type




Type TSpriteFrameAnimation
	'how many times animation should repeat until finished
	Field repeatTimes:int = 0
	'frame of sprite/image
	Field currentImageFrame:int = 0
	'position in frames-array
	Field currentFrame:int = 0
	Field frames:int[]
	'duration for each frame
	Field framesTime:float[]
	'stay with currentFrame or cycle through frames?
	Field paused:Int = FALSE
	Field frameTimer:float = null
	Field randomness:int = 0


	Function Create:TSpriteFrameAnimation(framesArray:int[][], repeatTimes:int=0, paused:int=0, randomness:int = 0)
		local obj:TSpriteFrameAnimation = new TSpriteFrameAnimation
		local framecount:int = len( framesArray )

		obj.frames		= obj.frames[..framecount] 'extend
		obj.framesTime	= obj.framesTime[..framecount] 'extend

		For local i:int = 0 until framecount
			obj.frames[i]		= framesArray[i][0]
			obj.framesTime[i]	= float(framesArray[i][1]) * 0.001
		Next
		obj.repeatTimes	= repeatTimes
		obj.paused = paused
		return obj
	End Function


	Function CreateSimple:TSpriteFrameAnimation(frameAmount:int, frameTime:int, repeatTimes:int=0, paused:int=0, randomness:int = 0)
		local f:int[][]
		For local i:int = 0 until frameAmount
			f :+ [[i,frameTime]]
		Next
		return Create(f, repeatTimes, paused, randomness)
	End Function


	Method Update:int()
		'skip update if only 1 frame is set
		'skip if paused
		If paused or frames.length <= 1 then return 0

		if frameTimer = null then ResetFrameTimer()
		frameTimer :- GetDeltaTimer().GetDelta()

		'time for next frame
		if frameTimer <= 0.0
			local nextPos:int = currentFrame + 1
			'increase current frameposition but only if frame is set
			'resets frametimer too
			setCurrentFrame(nextPos)

			'reached end? (use nextPos as setCurrentFramePos already limits value)
			If nextPos >= len(frames)
				If repeatTimes = 0
					Pause()	'stop animation
				Else
					setCurrentFrame(0)
					repeatTimes :-1
				EndIf
			EndIf
		Endif
	End Method


	Method Reset()
		setCurrentFrame(0)
	End Method


	Method ResetFrameTimer()
		frameTimer = framesTime[currentFrame] + Rand(-randomness, randomness)
	End Method


	Method GetFrameCount:int()
		return len(frames)
	End Method


	Method GetCurrentImageFrame:int()
		return currentImageFrame
	End Method


	Method SetCurrentImageFrame(frame:int)
		currentImageFrame = frame
		ResetFrameTimer()
	End Method


	Method GetCurrentFrame:int()
		return currentFrame
	End Method


	Method SetCurrentFrame(framePos:int)
		currentFrame = Max( Min(framePos, len(frames) - 1), 0)
		'set the image frame of thhe animation frame
		setCurrentImageFrame( frames[currentFrame] )
	End Method


	Method isPaused:Int()
		return paused
	End Method


	Method isFinished:Int()
		return paused AND (currentFrame >= len(frames)-1)
	End Method


	Method Playback()
		paused = 0
	End Method


	Method Pause()
		paused = 1
	End Method
End Type