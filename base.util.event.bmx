Rem
	===========================================================
	Event Manager
	===========================================================

	This class provides an event manager handling all incoming
	events.
ENDREM
SuperStrict
Import brl.Map
'Import brl.retro
?Threaded
Import Brl.threads
?
Import "base.util.logger.bmx"
Import "base.util.data.bmx"
Import "base.util.helper.bmx"




Global EventManager:TEventManager = New TEventManager
'do not forget to run: EventManager.Init() in your app

Type TEventManager
	Field _events:TList = New TList			' holding events
	Field _ticks:Int		= -1			' current time
	Field _listeners:TMap	= CreateMap()	' trigger => list of eventhandlers waiting for trigger


	Method getTicks:Int()
		Return _ticks
	End Method


	Method Init()
		'Assert _ticks = -1, "TEventManager: preparing to start event manager while already started"
		If _ticks = -1
			_events.Sort()				'sort by age
			_ticks = MilliSecs()		'begin
			TLogger.Log("TEventManager.Init()", "OK", LOG_LOADING)
		EndIf
	End Method


	Method isStarted:Int()
		Return _ticks > -1
	End Method


	Method isFinished:Int()
		Return _events.IsEmpty()
	End Method


	' add a new listener to a trigger
	Method registerListener:TLink(trigger:String, eventListener:TEventListenerBase)
		trigger = Lower(trigger)
		Local listeners:TList = TList(_listeners.ValueForKey(trigger))
		If listeners = Null									'if not existing, create a new list
			listeners = CreateList()
			_listeners.Insert(trigger, listeners)
		EndIf
		Return listeners.AddLast(eventListener)					'add to list of listeners
	End Method


	Method registerListenerFunction:TLink( trigger:String, _function(triggeredByEvent:TEventBase), limitToSender:Object=Null, limitToReceiver:Object=Null )
		Return registerListener( trigger, TEventListenerRunFunction.Create(_function, limitToSender, limitToReceiver) )
	End Method


	Method registerListenerMethod:TLink( trigger:String, objectInstance:Object, methodName:String, limitToSender:Object=Null, limitToReceiver:Object=Null )
		Return registerListener( trigger, TEventListenerRunMethod.Create(objectInstance, methodName, limitToSender, limitToReceiver) )
	End Method


	' remove an event from a trigger
	Method unregisterListener(trigger:String, eventListener:TEventListenerBase)
		Local listeners:TList = TList(_listeners.ValueForKey( Lower(trigger) ))
		If listeners <> Null Then listeners.remove(eventListener)
	End Method


	'remove all listeners having the given receiver or sender as limit
	Method unregisterListenerByLimit(limitReceiver:Object=Null, limitSender:Object=Null)
		For Local list:TList = EachIn _listeners
			For Local listener:TEventListenerBase = EachIn list
				'if one of both limits hits, remove that listener
				If THelper.ObjectsAreEqual(listener._limitToSender, limitSender) Or..
				   THelper.ObjectsAreEqual(listener._limitToReceiver, limitReceiver)
					list.remove(listener)
				EndIf
			Next
		Next
	End Method


	Method unregisterListenersByTrigger(trigger:String, limitReceiver:Object=Null, limitSender:Object=Null)
		'remove all of that trigger
		If Not limitReceiver And Not limitSender
			_listeners.remove( Lower(trigger) )
		'remove all defined by limits
		Else
			Local triggerListeners:TList = TList(_listeners.ValueForKey( Lower(trigger) ))
			For Local listener:TEventListenerBase = EachIn triggerListeners
				'if one of both limits hits, remove that listener
				If THelper.ObjectsAreEqual(listener._limitToSender, limitSender) Or..
				   THelper.ObjectsAreEqual(listener._limitToReceiver, limitReceiver)
					triggerListeners.remove(listener)
				EndIf
			Next
		EndIf
	End Method


	Method unregisterListenerByLink(link:TLink)
		link.remove()
	End Method


	' add a new event to the list
	Method registerEvent(event:TEventBase)
		_events.AddLast(event)
	End Method


	'runs all listeners NOW ...returns amount of listeners
	Method triggerEvent:Int(triggeredByEvent:TEventBase)
		?Threaded
		'if we have systemonly-event we cannot do it in a subthread
		'instead we just add that event to the upcoming events list
		If triggeredByEvent._channel = 1
			If CurrentThread()<>MainThread() Then registerEvent(triggeredByEvent)
		EndIf
		?


		Local listeners:TList = TList(_listeners.ValueForKey( Lower(triggeredByEvent._trigger) ))
		If listeners
			For Local listener:TEventListenerBase = EachIn listeners
				listener.onEvent(triggeredByEvent)
				'stop triggering the event if ONE of them vetos
				If triggeredByEvent.isVeto() Then Exit
			Next
			Return listeners.count()
		EndIf
		Return 0
	End Method


	Method update(onlyChannel:Int=Null)
		if not isStarted() then Init()	
		'Assert _ticks >= 0, "TEventManager: updating event manager that hasn't been prepared"
		_processEvents(onlyChannel)
		_ticks = MilliSecs()
	End Method


	Method _processEvents(onlyChannel:Int=Null)
		If Not _events.IsEmpty()
			Local event:TEventBase = TEventBase(_events.First()) 			' get the next event
			If event<> Null
				If onlyChannel<>Null
					'system
					?Threaded
					If event._channel = 1 And event._channel <> onlyChannel
						If CurrentThread()<>MainThread() Then Return
					EndIf
					?
				EndIf

'				Assert startTime >= self._ticks, "TEventManager: an future event didn't get triggered in time"
				If event.getStartTime() <= _ticks			' is it time for this event?
					event.onEvent()							' start event
					If event._trigger <> ""					' only trigger event if _trigger is set
						triggerEvent( event )
					EndIf
					_events.RemoveFirst()			' remove from list
					_processEvents()				' another event may start on the same ticks - check again
				EndIf
			EndIf
		EndIf
	End Method
End Type




Type TEventListenerBase
	Field _limitToSender:Object		= Null
	Field _limitToReceiver:Object	= Null


	Method OnEvent:Int(triggeredByEvent:TEventBase) Abstract


	'returns whether to ignore the incoming event (eg. limits...)
	'an event can be ignored if the sender<>limitSender or receiver<>limitReceiver
	Method ignoreEvent:Int(triggerEvent:TEventBase)
		If triggerEvent = Null Then Return True

		'Check limit for "sender"
		'if the listener wants a special sender but the event does not have one... ignore
		'old if self._limitToSender and triggerEvent._sender
		'new
		If _limitToSender
			'we want a sender but got none - ignore (albeit objects are NOT equal)
			If Not triggerEvent._sender Then Return True

			If Not THelper.ObjectsAreEqual(triggerEvent._sender, _limitToSender) Then Return True
		EndIf

		'Check limit for "receiver" - but only if receiver is set
		'if the listener wants a special receiver but the event does not have one... ignore
		'old: if self._limitToReceiver and triggerEvent._receiver
		'new
		If _limitToReceiver
			'we want a receiver but got none - ignore (albeit objects are NOT equal)
			If Not triggerEvent._receiver Then Return True

			If Not THelper.ObjectsAreEqual(triggerEvent._receiver, _limitToReceiver) Then Return True
		EndIf

		Return False
	End Method
End Type




Type TEventListenerRunMethod Extends TEventListenerBase
	Field _methodName:String = ""
	Field _objectInstance:Object

	Function Create:TEventListenerRunMethod(objectInstance:Object, methodName:String, limitToSender:Object=Null, limitToReceiver:Object=Null )
		Local obj:TEventListenerRunMethod = New TEventListenerRunMethod
		obj._methodName			= methodName
		obj._objectInstance		= objectInstance
		obj._limitToSender		= limitToSender
		obj._limitToReceiver	= limitToReceiver
		Return obj
	End Function


	Method OnEvent:Int(triggerEvent:TEventBase)
		If triggerEvent = Null Then Return 0

		If Not Self.ignoreEvent(triggerEvent)
			Local id:TTypeId		= TTypeId.ForObject( _objectInstance )
			Local update:TMethod	= id.FindMethod( _methodName )

			update.Invoke(_objectInstance ,[triggerEvent])
			Return True
		EndIf

		Return True
	End Method
End Type




Type TEventListenerRunFunction Extends TEventListenerBase
	Field _function(triggeredByEvent:TEventBase)

	Function Create:TEventListenerRunFunction(_function(triggeredByEvent:TEventBase), limitToSender:Object=Null, limitToReceiver:Object=Null )
		Local obj:TEventListenerRunFunction = New TEventListenerRunFunction
		obj._function			= _function
		obj._limitToSender		= limitToSender
		obj._limitToReceiver	= limitToReceiver
		Return obj
	End Function


	Method OnEvent:Int(triggerEvent:TEventBase)
		If triggerEvent = Null Then Return 0

		If Not ignoreEvent(triggerEvent) Then Return _function(triggerEvent)

		Return True
	End Method
End Type




Type TEventBase
	Field _startTime:Int
	Field _trigger:String = ""
	Field _sender:Object = Null
	Field _receiver:Object = Null
	Field _data:Object
	Field _status:Int = 0
	Field _channel:Int = 0		'no special channel

	Const STATUS_VETO:Int = 1
	Const STATUS_ACCEPTED:Int = 2


	Method getStartTime:Int()
		Return _startTime
	End Method


	Method setStartTime:TEventBase(newStartTime:Int=0)
		_startTime = newStartTime
		Return Self
	End Method


	Method delayStart:TEventBase(delayMilliseconds:Int=0)
		_startTime :+ delayMilliseconds

		Return Self
	End Method


	Method setStatus(status:Int, enable:Int=True)
		If enable
			_status :| status
		Else
			_status :& ~status
		EndIf
	End Method


	Method setVeto(bool:Int=True)
		setStatus(STATUS_VETO, bool)
	End Method


	Method isVeto:Int()
		Return (_status & STATUS_VETO)
	End Method


	Method setAccepted(bool:Int=True)
		setStatus(STATUS_ACCEPTED, bool)
	End Method


	Method isAccepted:Int()
		Return (_status & STATUS_ACCEPTED)
	End Method


	Method onEvent()
	End Method


	Method GetReceiver:Object()
		Return _receiver
	End Method


	Method GetSender:Object()
		Return _sender
	End Method


	Method GetData:TData()
		Return TData(_data)
	End Method


	Method getTrigger:String()
		Return Lower(_trigger)
	End Method


	'returns wether trigger is the same
	Method isTrigger:Int(trigger:String)
		Return _trigger = Lower(trigger)
	End Method


	' to sort the event queue by time
	Method Compare:Int(other:Object)
		Local event:TEventBase = TEventBase(other)
		If Not event Then Return Super.Compare(other)

		If getStartTime() > event.getStartTime() Then Return 1 .. 			' i'm newer
		Else If getStartTime() < event.getStartTime() Then Return -1 ..	' they're newer
		Else Return 0
	End Method
End Type




Type TEventSimple Extends TEventBase
	Function Create:TEventSimple(trigger:String, data:Object=Null, sender:Object=Null, receiver:Object=Null, channel:Int=0)
		If data = Null Then data = New TData
		Local obj:TEventSimple = New TEventSimple
		obj._trigger	= Lower(trigger)
		obj._data	 	= data
		obj._sender		= sender
		obj._receiver	= receiver
		obj._channel	= channel
		obj.setStartTime( EventManager.getTicks() )
		Return obj
	End Function
End Type
