REM
	===========================================================
	Input classes
	===========================================================

	There are 3 Managers:

	TMouseManager: Mouse position, buttons ...
	TKeyManager: key states ...
	TKeyWrapper: managing "hold down" states for keys
ENDREM
SuperStrict
Import brl.System
Import brl.PolledInput
Import "base.util.point.bmx"

Global MOUSEMANAGER:TMouseManager = New TMouseManager
Global KEYMANAGER:TKeyManager = New TKeyManager
Global KEYWRAPPER:TKeyWrapper = New TKeyWrapper


Const KEY_STATE_NORMAL:int		= 0
Const KEY_STATE_HIT:int			= 1
Const KEY_STATE_DOWN:int		= 2
Const KEY_STATE_UP:int			= 3
Const KEY_STATE_DOUBLEHIT:int	= 4
Const KEY_STATE_CLICKED:int		= 5
Const KEY_STATE_BLOCKED:int		= 6

For local i:int = 0 To 255
	KEYWRAPPER.allowKey(i,KEYWRAP_ALLOW_BOTH,600,100)
Next


Type TMouseManager
	Field lastPos:TPoint = new TPoint
	Field x:float = 0.0
	Field y:float = 0.0

	Field hasMoved:int = FALSE
	'amount of pixels moved (0=zero, -upwards, +downwards)
	Field scrollWheelMoved:int = 0
	'current status of the buttons
	Field _keyStatus:Int[] = [0,0,0,0]
	'time since when the button is pressed
	Field _keyDownTime:Int[] = [0,0,0,0]
	'time when the button was last hit
	Field _keyHitTime:Int[]	= [0,0,0,0]
	'ms between two clicks for 1 double click
	Field _doubleClickTime:int = 300


	'returns whether the button is in normal state
	Method isNormal:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_NORMAL
	End Method


	'returns whether the button is in hit state
	Method isHit:Int(key:Int, ignoreDoubleClicks:int=TRUE)
		if ignoreDoubleClicks then return _keyStatus[key] = KEY_STATE_HIT
		return (_keyStatus[key] = KEY_STATE_HIT) or (_keyStatus[key] = KEY_STATE_DOUBLEHIT) or (_keyStatus[key] = KEY_STATE_CLICKED)
	End Method


	'returns whether the button is in doublehit state
	Method isDoubleHit:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_DOUBLEHIT
	EndMethod


	'returns whether the button is in clicked state
	Method isClicked:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_CLICKED
	End Method


	'returns whether the button is in down state
	Method isDown:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_DOWN
	End Method


	'returns how many milliseconds a button is down
	Method isDownTime:Int(key:Int)
		if _keyDownTime[key] > 0
			return Millisecs() - _keyDownTime[key]
		else
			return 0
		endif
	End Method


	'returns whether the button is in up state
	Method isUp:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_UP
	End Method


	Method SetDown:Int(key:Int)
		_keyStatus[key] = KEY_STATE_DOWN
	End Method


	'Update the button state
	Method Update:Int()
		hasMoved = False
		If lastPos.x <> MouseX() Or lastPos.y <> MouseY()
			hasMoved = True
			lastPos.SetXY(MouseX(), MouseY())
		endif
		scrollWheelMoved = 0
		if lastPos.z <> MouseZ()
			scrollWheelMoved = lastPos.z - MouseZ()
			lastPos.z = MouseZ()
		endif
		x = MouseX()
		y = MouseY()

		For Local i:Int = 1 To 3
			If _keyStatus[i] = KEY_STATE_NORMAL
				If MouseHit(i)
					_keyStatus[i] = KEY_STATE_HIT
					'check for double click
					'only act if we already clicked in the past
					if _keyHitTime[i] > 0
						'did we click in the time frame ?
						if _keyHitTime[i] + _doubleClickTime > Millisecs()
							_keyStatus[i] = KEY_STATE_DOUBLEHIT
							_keyHitTime[i] = 0
						else
							'start a new doubleclick time
							_keyHitTime[i] = millisecs()
						endif
					else
						'save the click time so we now the passed time on next click
						_keyHitTime[i] = millisecs()
					endif

				endif
			ElseIf _keyStatus[i] = KEY_STATE_HIT or _keyStatus[i] = KEY_STATE_DOUBLEHIT or _keyStatus[i] = KEY_STATE_CLICKED
				If MouseDown(i) Then _keyStatus[i] = KEY_STATE_DOWN Else _keyStatus[i] = KEY_STATE_UP
			ElseIf _keyStatus[i] = KEY_STATE_DOWN
				If Not MouseDown(i) Then _keyStatus[i] = KEY_STATE_UP
			ElseIf _keyStatus[i] = KEY_STATE_UP
				_keyStatus[i] = KEY_STATE_NORMAL
			EndIf

			if MouseDown(i)
				'store time when first mousedown happened
				if _keyDownTime[i] = 0 then _keyDownTime[i] = millisecs()
			Else
				if _keyDownTime[i] > 0 then _keyStatus[i] = KEY_STATE_CLICKED
				'reset time - mousedown no longer happening
				_keyDownTime[i] = 0
			endif
		Next
	End Method

	'deprecated
	Method changeStatus()
		Update()
	End Method


	'reset the state of the given button
	Method resetKey:Int(key:Int)
		_keyDownTime[key] = 0
		_keyStatus[key] = KEY_STATE_UP
		Return KEY_STATE_UP
	End Method


	'returns array of bools describing down state of each button
	Method getStatusDown:int[]()
		return [false,..
		        _keyStatus[1] = KEY_STATE_DOWN,..
		        _keyStatus[2] = KEY_STATE_DOWN,..
		        _keyStatus[3] = KEY_STATE_DOWN..
		        ]
	End Method


	'returns array of bools describing hit/doublehit state of each button
	Method getStatusHit:int[]()
		return [false,..
		        _keyStatus[1] = (KEY_STATE_HIT or KEY_STATE_DOUBLEHIT),..
		        _keyStatus[2] = (KEY_STATE_HIT or KEY_STATE_DOUBLEHIT),..
		        _keyStatus[3] = (KEY_STATE_HIT or KEY_STATE_DOUBLEHIT)..
		        ]
	End Method


	'returns array of bools describing clicked state of each button
	Method getStatusClicked:int[]()
		return [false,..
		        _keyStatus[1] = KEY_STATE_CLICKED,..
		        _keyStatus[2] = KEY_STATE_CLICKED,..
		        _keyStatus[3] = KEY_STATE_CLICKED..
		        ]
	End Method


	'returns the status of a button
	Method getStatus:Int(key:Int)
		Return _keyStatus[key]
	End Method


	'returns positive or negative value describing the movement
	'of the scrollwheel
	Method getScrollwheelMovement:int()
		return scrollWheelMoved
	End Method
EndType




Type TKeyManager
	'status of all keys
	Field _keyStatus:Int[256]
	Field _blockKeyTime:Int[256]


	'returns whether the button is in normal state
	Method isNormal:Int(key:Int)
		return _keyStatus[Key] = KEY_STATE_NORMAL
	End Method


	'returns whether the button is currently blocked
	Method isBlocked:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_BLOCKED
	End Method


	'returns whether the button is in hit state
	Method isHit:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_HIT
	End Method


	'returns whether the button is in down state
	Method isDown:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_DOWN
	End Method


	'returns whether the button is in up state
	Method isUp:Int(key:Int)
		return _keyStatus[key] = KEY_STATE_UP
	End Method


	'refresh all key states
	Method Update:Int())
		local time:int = Millisecs()
		For Local i:Int = 1 To 255
			'ignore key if it is blocked
			'or set back to "normal" afterwards
			if _blockKeyTime[i] > time
				_keyStatus[i] = KEY_STATE_BLOCKED
			elseif _keyStatus[i] = KEY_STATE_BLOCKED
				_keyStatus[i] = KEY_STATE_NORMAL
			endif

			'normal check
			If _keyStatus[i] = KEY_STATE_NORMAL
				If KeyDown(i) Then _keyStatus[i] = KEY_STATE_HIT
			ElseIf _keyStatus[i] = KEY_STATE_HIT
				If KeyDown(i) Then _keyStatus[i] = KEY_STATE_DOWN Else _keyStatus[i] = KEY_STATE_UP
			ElseIf _keyStatus[i] = KEY_STATE_DOWN
				If Not KeyDown(i) Then _keyStatus[i] = KEY_STATE_UP
			ElseIf _keyStatus[i] = KEY_STATE_UP
				_keyStatus[i] = KEY_STATE_NORMAL
			EndIf
		Next
	End Method


	'deprecated
	Method changeStatus()
		Update()
	End Method


	'returns the status of a key
	Method getStatus:Int(key:Int)
		Return _keyStatus[key]
	End Method


	'set a key as blocked for the given time
	Method blockKey:int(key:int, milliseconds:int=0)
		'time can be absolute as a key block is just for blocking a key
		'which has not to be deterministic
		_blockKeyTime[key] = millisecs() + milliseconds
		'also set the current status to blocked
		_keyStatus[key] = KEY_STATE_BLOCKED
	End Method


	'resets the keys status
	Method resetKey:Int(key:Int)
		_keyStatus[key] = KEY_STATE_UP
		Return KEY_STATE_UP
	End Method
EndType




Const KEYWRAP_ALLOW_HIT:int	= 1
Const KEYWRAP_ALLOW_HOLD:int= 2
Const KEYWRAP_ALLOW_BOTH:int= 3


Type TKeyWrapper
	Rem
		0 - --
		1 - time to wait to get "hold" state after "hit"
		2 - time to wait for next "hold" after "hold"
		3 - total time till next hold
	EndRem
	Field _keySet:Int[256, 4]


	Method allowKey(key:Int, rule:Int=KEYWRAP_ALLOW_BOTH, hitTime:Int=600, holdtime:Int=100)
		_keySet[key, 0] = rule
		If rule & KEYWRAP_ALLOW_HIT then _keySet[key, 1] = hitTime

		If rule & KEYWRAP_ALLOW_HOLD then _keySet[key, 2] = holdTime
	End Method


	Method pressedKey:Int(key:Int, keyState:int=-1)
		if keyState = -1 then keyState = KEYMANAGER.getStatus(key)
		Local rule:Int = _keySet[key, 0]

		If keyState = KEY_STATE_NORMAL or keyState = KEY_STATE_UP Then Return False
		If keyState = KEY_STATE_BLOCKED Then Return False

		'Muss erlaubt und aktiv sein
		If rule & KEYWRAP_ALLOW_HIT and keyState = KEY_STATE_HIT
			Return hitKey(key, keyState)
		ElseIf rule & KEYWRAP_ALLOW_HOLD
			return holdKey(key, keyState)
		EndIf
		Return False
	End Method


	Method hitKey:Int(key:Int, keyState:int=-1)
		if keyState = -1 then keyState = KEYMANAGER.getStatus(key)
		If keyState <> KEY_STATE_HIT Then Return False

		'Muss erlaubt und aktiv sein
		If _keySet[key, 0] & KEYWRAP_ALLOW_HIT
			'Zeit bis man Taste halten darf
			_keySet[key, 3] = MilliSecs() + _keySet[key, 1]
			Return True
		EndIf
		Return False
	End Method


	Method holdKey:Int(key:Int, keyState:int=-1)
		if keyState = -1 then keyState = KEYMANAGER.getStatus(key)
		If keyState = KEY_STATE_NORMAL Or keyState = KEY_STATE_UP Then Return False

		If _keySet[key, 0] & KEYWRAP_ALLOW_HOLD
			'Zeit die verstrichen sein muss
			Local time:Int = _keySet[key, 3]
			If MilliSecs() > time
				'Zeit bis zum naechsten "gedrueckt" aktualisieren
				_keySet[key, 3] = MilliSecs() + _keySet[key, 2]
				Return True
			EndIf
		EndIf
		Return False
	End Method


	Method resetKey(key:Int)
		_keySet[key, 0] = 0
		_keySet[key, 1] = 0
		_keySet[key, 2] = 0
		_keySet[key, 3] = 0
	End Method
End Type