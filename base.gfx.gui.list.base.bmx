Rem
	===========================================================
	GUI Basic List
	===========================================================

	Code contains:
	- TGUIListBase: basic list
	- TGUIListItem: basic list item
End Rem
SuperStrict
Import "base.gfx.gui.bmx"
Import "base.gfx.gui.scroller.bmx"
Import "base.gfx.gui.panel.scrollablepanel.bmx"
Import "base.util.helper.bmx"




Type TGUIListBase Extends TGUIobject
	Field guiBackground:TGUIobject = Null
	Field backgroundColor:TColor = TColor.Create(0,0,0,0)
	Field backgroundColorHovered:TColor	= TColor.Create(0,0,0,0)
	Field guiEntriesPanel:TGUIScrollablePanel = Null
	Field guiScrollerH:TGUIScroller = Null
	Field guiScrollerV:TGUIScroller	= Null

	Field autoScroll:Int = False
	'hide scroller if mouse not over parent
	Field autoHideScroller:Int = False
	'we need it to do a "one time" auto scroll
	Field scrollerUsed:Int = False
	Field entries:TList	= CreateList()
	Field entriesLimit:Int = -1
	Field autoSortItems:Int	= True
	Field _multiColumn:int	= FALSE
	'private mouseover-field (ignoring covering child elements)
	Field _mouseOverArea:Int = False
	Field _dropOnTargetListenerLink:TLink = Null
	'displace each entry by (z-value is stepping)...
	Field _entryDisplacement:TVec3D	= new TVec3D.Init(0, 0, 1)
	'displace the entriesblock by x,y...
	Field _entriesBlockDisplacement:TVec3D = new TVec3D.Init(0, 0, 0)
	'orientation of the list: 0 means vertical, 1 is horizontal
	Field _orientation:Int = 0
	Field _scrollingEnabled:Int	= False
	'scroll to the very first element as soon as the scrollbars get hidden ?
	Field _scrollToBeginWithoutScrollbars:Int = True


    Method Create:TGUIListBase(position:TVec2D = null, dimension:TVec2D = null, limitState:String = "")
		Super.CreateBase(position, dimension, limitState)

		setZIndex(0)

		guiScrollerH = New TGUIScroller.Create(Self)
		guiScrollerV = New TGUIScroller.Create(Self)
		'orientation of horizontal scroller has to get set manually
		guiScrollerH.SetOrientation(GUI_OBJECT_ORIENTATION_HORIZONTAL)

		guiEntriesPanel = New TGUIScrollablePanel.Create(null, new TVec2D.Init(rect.GetW() - guiScrollerV.rect.getW(), rect.GetH() - guiScrollerH.rect.getH()), self.state)

		AddChild(guiEntriesPanel) 'manage by our own


		'by default all lists accept drop
		setOption(GUI_OBJECT_ACCEPTS_DROP, True)
		'by default all lists do not have scrollers
		setScrollerState(False, False)

		'the entries panel cannot be focused
		guiEntriesPanel.setOption(GUI_OBJECT_CAN_GAIN_FOCUS, False)


		autoSortItems = True


		'register events
		'someone uses the mouse wheel to scroll over the panel
		AddEventListener(EventManager.registerListenerFunction( "guiobject.OnScrollwheel", onScrollWheel, Self))
		'- we are interested in certain events from the scroller or self
		AddEventListener(EventManager.registerListenerFunction( "guiobject.onScrollPositionChanged", onScroll, guiScrollerH ))
		AddEventListener(EventManager.registerListenerFunction( "guiobject.onScrollPositionChanged", onScroll, guiScrollerV ))
		AddEventListener(EventManager.registerListenerFunction( "guiobject.onScrollPositionChanged", onScroll, self ))


		'is something dropping - check if it this list
		SetAcceptDrop("TGUIListItem")

		GUIManager.Add(Self)
		Return Self
	End Method


	Method EmptyList:Int()
		For Local obj:TGUIobject = EachIn entries
			'call the objects cleanup-method and unsets the object
'			GUIManager.DeleteObject(obj)
			obj.remove()
			GUIManager.Remove(obj)
			obj = null
		Next
		'overwrite the list with a new one
		entries = CreateList()
	End Method


	Method SetEntryDisplacement(x:Float=0.0, y:Float=0.0, stepping:Int=1)
		_entryDisplacement.SetXYZ(x,y, Max(1,stepping))
	End Method


	Method SetEntriesBlockDisplacement(x:Float=0.0, y:Float=0.0)
		_entriesBlockDisplacement.SetXY(x,y)
	End Method


	Method SetOrientation(orientation:Int=0)
		_orientation = orientation
	End Method


	Method SetMultiColumn(bool:int=FALSE)
		if _multiColumn <> bool
			_multiColumn = bool
			'maybe now more or less elements fit into the visible
			'area, so elements position need to get recalculated
			RecalculateElements()
		endif
	End Method


	Method SetBackground(background:TGUIobject)
		'set old background to managed again
		If guiBackground Then GUIManager.add(guiBackground)
		'assign new background
		guiBackground = background
		If guiBackground
			guiBackground.setParent(Self)
			'set to unmanaged in all cases
			GUIManager.remove(guiBackground)
		EndIf
	End Method


	'override resize and add minSize-support
	'size 0, 0 is not possible (leads to autosize)
	Method Resize(w:Float = 0, h:Float = 0)
		Super.Resize(w,h)

		'cache enabled state of both scrollers
		local showScrollerH:int = 0<(guiScrollerH and guiScrollerH.hasOption(GUI_OBJECT_ENABLED))
		local showScrollerV:int = 0<(guiScrollerV and guiScrollerV.hasOption(GUI_OBJECT_ENABLED))


		'resize panel - but use resulting dimensions, not given (maybe restrictions happening!)
		If guiEntriesPanel
			'also set minsize so scroll works
			guiEntriesPanel.minSize.SetXY(..
				GetContentScreenWidth() + _entriesBlockDisplacement.x - showScrollerV*guiScrollerV.GetScreenWidth(),..
				GetContentScreenHeight() + _entriesBlockDisplacement.y - showScrollerH*guiScrollerH.rect.getH()..
			)

			guiEntriesPanel.Resize(..
				GetContentScreenWidth() + _entriesBlockDisplacement.x - showScrollerV * guiScrollerV.rect.getW(),..
				GetContentScreenHeight() + _entriesBlockDisplacement.y - showScrollerH * guiScrollerH.rect.getH()..
			)
		EndIf

		'move horizontal scroller --
		If showScrollerH and not guiScrollerH.hasOption(GUI_OBJECT_POSITIONABSOLUTE)
			guiScrollerH.rect.position.setXY(_entriesBlockDisplacement.x, GetContentScreenHeight() + _entriesBlockDisplacement.y - guiScrollerH.guiButtonMinus.rect.getH())
			if showScrollerV
				guiScrollerH.Resize(GetScreenWidth() - guiScrollerV.GetScreenWidth(), 0)
			else
				guiScrollerH.Resize(GetScreenWidth())
			endif
		EndIf
		'move vertical scroller |
		If showScrollerV and not guiScrollerV.hasOption(GUI_OBJECT_POSITIONABSOLUTE)
			guiScrollerV.rect.position.setXY( GetContentScreenWidth() + _entriesBlockDisplacement.x - guiScrollerV.guiButtonMinus.rect.getW(), _entriesBlockDisplacement.y)
			if showScrollerH
				guiScrollerV.Resize(0, GetContentScreenHeight() - guiScrollerH.GetScreenHeight()-03)
			else
				guiScrollerV.Resize(0, GetContentScreenHeight())
			endif
		EndIf

		If guiBackground
			'move background by negative padding values ( -> ignore padding)
			guiBackground.rect.position.setXY(-GetPadding().getLeft(), -GetPadding().getTop())

			'background covers whole area, so resize it
			guiBackground.resize(rect.getW(), rect.getH())
		EndIf
	End Method


	Method SetAcceptDrop:Int(accept:Object)
		'if we registered already - remove the old one
		If _dropOnTargetListenerLink Then EventManager.unregisterListenerByLink(_dropOnTargetListenerLink)

		'is something dropping - check if it is this list
		_dropOnTargetListenerLink = EventManager.registerListenerFunction( "guiobject.onDropOnTarget", onDropOnTarget, accept, Self)
	End Method


	Method SetItemLimit:Int(limit:Int)
		entriesLimit = limit
	End Method


	Method ReachedItemLimit:Int()
		If entriesLimit <= 0 Then Return False
		Return (entries.count() >= entriesLimit)
	End Method


	Method GetItemByCoord:TGUIobject(coord:TVec2D)
		For Local entry:TGUIobject = EachIn entries
			'our entries are sorted and replaced, so we could
			'quit as soon as the
			'entry is out of range...
			If entry.GetScreenY() > GetScreenY()+GetScreenHeight() Then Return Null
			If entry.GetScreenX() > GetScreenX()+GetScreenWidth() Then Return Null

			If entry.GetScreenRect().containsXY(coord.GetX(), coord.GetY()) Then Return entry
		Next
		Return Null
	End Method


	'base handling of add item
	Method _AddItem:Int(item:TGUIobject, extra:Object=Null)
'		if self.ReachedItemLimit() then return FALSE

		'set parent of the item - so item is able to calculate position
		guiEntriesPanel.addChild(item )

		'recalculate dimensions as the item now knows its parent
		'so a normal AddItem-handler can work with calculated dimensions from now on
		'Local dimension:TVec2D = item.getDimension()

		entries.addLast(item)

		'run the custom compare method
		If autoSortItems Then entries.sort()

		EventManager.triggerEvent(TEventSimple.Create("guiList.addItem", new TData.Add("item", item) , Self))

		Return True
	End Method


	'base handling of remove item
	Method _RemoveItem:Int(item:TGUIobject)
		If entries.Remove(item)
			'remove from panel and item gets managed by guimanager
			guiEntriesPanel.removeChild(item)

			EventManager.triggerEvent(TEventSimple.Create("guiList.removeItem", new TData.Add("item", item) , Self))
			
			Return True
		Else
			Print "not able to remove item "+item._id
			Return False
		EndIf
	End Method


	'overrideable AddItem-Handler
	Method AddItem:Int(item:TGUIobject, extra:Object=Null)
		If _AddItem(item, extra)
			'recalculate positions, dimensions etc.
			RecalculateElements()

			Return True
		EndIf
		Return False
	End Method
	'overrideable RemoveItem-Handler
	Method RemoveItem:Int(item:TGUIobject)
		If _RemoveItem(item)
			RecalculateElements()

			Return True
		EndIf
		Return False
	End Method


	Method HasItem:Int(item:TGUIobject)
		For Local otheritem:TGUIobject = EachIn entries
			If otheritem = item Then Return True
		Next
		Return False
	End Method


	Method IsAtListBottom:int()
		local result:int = 1 > Floor(Abs(guiEntriesPanel.scrollLimit.GetY() - guiEntriesPanel.scrollPosition.getY()))

		'if all items fit on the screen, scroll limit will be
		'lower than the container panel 
		if Abs(guiEntriesPanel.scrollLimit.GetY()) < guiEntriesPanel.GetScreenHeight()
			'if scrolled = 0 this could also mean we scrolled up to the top part
			'in this case we check if the last item in the list fits into the
			'panel
			if guiEntriesPanel.scrollPosition.getY() = 0
				result = 1
				local lastItem:TGUIListItem = TGUIListItem(entries.Last())
				if lastItem and lastItem.GetScreenY() > guiEntriesPanel.getScreenY() + guiEntriesPanel.getScreenheight()
					result = 0
				endif
			endif
		endif
		return result
	End Method


	'recalculate scroll maximas, item positions...
	Method RecalculateElements:Int()
		local startPos:TVec3D = _entriesBlockDisplacement.copy()
		Local dimension:TVec3D = _entriesBlockDisplacement.copy()
		Local entryNumber:Int = 1
		Local nextPos:TVec3D = startPos.copy()
		Local currentPos:TVec3D
		local columnPadding:int = 5

		For Local entry:TGUIobject = EachIn entries
			currentPos = nextPos.copy()

			'==== CALCULATE POSITION ====
			Select _orientation
				'only from top to bottom
				Case GUI_OBJECT_ORIENTATION_VERTICAL
					'MultiColumn: from left to right, if space left a
					'             new column on the right is started.

					'advance the next position starter
					if _multiColumn
						'if entry does not fit, try the next line
						if currentPos.GetX() + entry.rect.GetW() > GetContentScreenWidth()
							currentPos.SetXY(startPos.GetX(), currentPos.GetY() + entry.rect.GetH())
							'new lines increase dimension of container
							dimension.AddXY(0, entry.rect.GetH())
						endif

						nextPos = currentPos.copy()
						nextPos.AddXY(entry.rect.GetW() + columnPadding, 0)
					else
						nextPos = currentPos.copy()
						nextPos.AddXY(0, entry.rect.GetH())
						'new lines increase dimension of container
						dimension.AddXY(0, entry.rect.GetH())
					endif

				Case GUI_OBJECT_ORIENTATION_HORIZONTAL
					'MultiColumn: from top to bottom, if space left a
					'             new line below is started.

					'advance the next position starter
					if _multiColumn
						'if entry does not fit, try the next row
						if currentPos.GetY() + entry.rect.GetH() > GetContentScreenHeight()
							currentPos.SetXY(currentPos.GetX() + entry.rect.GetW(), startPos.GetY())
							'new lines increase dimension of container
							dimension.AddXY(entry.rect.GetW(), 0 )
						endif

						nextPos = currentPos.copy()
						nextPos.AddXY(0, entry.rect.GetH() + columnPadding)
					else
						nextPos = currentPos.copy()
						nextPos.AddXY(entry.rect.GetW(),0)
						'new lines increase dimension of container
						dimension.AddXY(entry.rect.GetW(), 0 )
					endif
			End Select

			'==== ADD POTENTIAL DISPLACEMENT ====
			'add the displacement afterwards - so the first one is not displaced
			If entryNumber Mod _entryDisplacement.z = 0 And entry <> entries.last()
				currentPos.AddXY(_entryDisplacement.x, _entryDisplacement.y)
				'increase dimension if positive displacement
				dimension.AddXY( Max(0,_entryDisplacement.x), Max(0, _entryDisplacement.y))
			EndIf

			'==== SET POSITION ====
			entry.rect.position.CopyFrom(currentPos.ToVec2D())

			entryNumber:+1
		Next

		'resize container panel
		guiEntriesPanel.resize(dimension.getX(), dimension.getY())

		Select _orientation
			'===== VERTICAL ALIGNMENT =====
			case GUI_OBJECT_ORIENTATION_VERTICAL
				'determine if we did not scroll the list to a middle
				'position so this is true if we are at the very bottom
				'of the list aka "the end"
				Local atListBottom:Int = IsAtListBottom()

				'set scroll limits:
				if dimension.getY() < guiEntriesPanel.getScreenheight()
					'if there are only some elements, they might be
					'"less high" than the available area - no need to
					'align them at the bottom
					guiEntriesPanel.SetLimits(0, -dimension.getY())
				Else
					'maximum is at the bottom of the area, not top - so
					'subtract height
					'old: guiEntriesPanel.SetLimits(0, -(dimension.getY() - guiEntriesPanel.getScreenheight()) )
					local lastItem:TGUIListItem = TGUIListItem(entries.Last())
					if not lastItem
						guiEntriesPanel.SetLimits(0, 0)
					else
'						if not autoScroll
'							guiEntriesPanel.SetLimits(0, - (dimension.getY() - guiEntriesPanel.getScreenheight() - lastItem.GetScreenHeight()))
'						else
							guiEntriesPanel.SetLimits(0, - (dimension.getY() - guiEntriesPanel.getScreenheight()))
'						endif
					endif
					'in case of auto scrolling we should consider
					'scrolling to the next visible part
					If autoscroll And (Not scrollerUsed Or atListBottom) Then scrollToLastItem()
				EndIf
			'===== HORIZONTAL ALIGNMENT =====
			case GUI_OBJECT_ORIENTATION_HORIZONTAL
				'determine if we did not scroll the list to a middle
				'position so this is true if we are at the very right
				'of the list aka "the end"
				Local atListBottom:Int = 1 > Floor( Abs(guiEntriesPanel.scrollLimit.GetX() - guiEntriesPanel.scrollPosition.getX() ) )

				'set scroll limits:
				If dimension.getX() < guiEntriesPanel.getScreenWidth()
					'if there are only some elements, they might be
					'"less high" than the available area - no need to
					'align them at the right
					guiEntriesPanel.SetLimits(-dimension.getX(), 0 )
				Else
					'maximum is at the bottom of the area, not top - so
					'subtract height
					'old: guiEntriesPanel.SetLimits(-(dimension.getX() - guiEntriesPanel.getScreenWidth()), 0)
					local lastItem:TGUIListItem = TGUIListItem(entries.Last())
					if not lastItem
						guiEntriesPanel.SetLimits(0, 0)
					else
						guiEntriesPanel.SetLimits(- (dimension.getX() - guiEntriesPanel.getScreenWidth() - lastItem.GetScreenWidth()), 0)
					endif

					'in case of auto scrolling we should consider
					'scrolling to the next visible part
					If autoscroll And (Not scrollerUsed Or atListBottom) Then scrollToLastItem()
				EndIf

		End Select

		guiScrollerH.SetValueRange(0, dimension.getX())
		guiScrollerV.SetValueRange(0, dimension.getY())


		'if not all entries fit on the panel, enable scroller
		SetScrollerState(..
			dimension.getX() > guiEntriesPanel.GetScreenWidth(), ..
			dimension.getY() > guiEntriesPanel.GetScreenHeight() ..
		)
	End Method


	Method SetScrollerState:int(boolH:int, boolV:int)
		'set scrolling as enabled or disabled
		_scrollingEnabled = (boolH or boolV)

		local changed:int = FALSE
		if boolH <> guiScrollerH.hasOption(GUI_OBJECT_ENABLED) then changed = TRUE
		if boolV <> guiScrollerV.hasOption(GUI_OBJECT_ENABLED) then changed = TRUE

		'as soon as the scroller gets disabled, we scroll to the first
		'item.
		'ATTENTION: if you do not want this behaviour, set the variable below
		'           accordingly
		if changed and _scrollToBeginWithoutScrollbars
			if not _scrollingEnabled then ScrollToFirstItem()
		End If


		guiScrollerH.setOption(GUI_OBJECT_ENABLED, boolH)
		guiScrollerH.setOption(GUI_OBJECT_VISIBLE, boolH)
		guiScrollerV.setOption(GUI_OBJECT_ENABLED, boolV)
		guiScrollerV.setOption(GUI_OBJECT_VISIBLE, boolV)

		'resize everything
		Resize()
	End Method


	'override default
	Method onDrop:Int(triggerEvent:TEventBase)
		'we could check for dragged element here
		triggerEvent.setAccepted(True)
		Return True
	End Method


	'default handler for the case of an item being dropped back to its
	'parent list
	'by default it does not handly anything, so returns FALSE
	Method HandleDropBack:Int(triggerEvent:TEventBase)
		Return False
	End Method


	Function onDropOnTarget:Int( triggerEvent:TEventBase )
		Local item:TGUIListItem = TGUIListItem(triggerEvent.GetSender())
		If item = Null Then Return False

		'ATTENTION:
		'Item is still in dragged state!
		'Keep this in mind when sorting the items

		'only handle if coming from another list ?
		Local parent:TGUIobject = item._parent
		If TGUIPanel(parent) Then parent = TGUIPanel(parent)._parent
		Local fromList:TGUIListBase = TGUIListBase(parent)
		'if not fromList then return FALSE

		Local toList:TGUIListBase = TGUIListBase(triggerEvent.GetReceiver())
		If Not toList Then Return False

		Local data:TData = triggerEvent.getData()
		If Not data Then Return False

		If fromList = toList
			'if the handler took care of everything, we skip
			'removing and adding the item
			If fromList.HandleDropBack(triggerEvent)
				'inform others about that dropback
				EventManager.triggerEvent( TEventSimple.Create("guiobject.onDropBack", null , item, toList))
				Return True
			endif
		EndIf
'method A
		'move item if possible
		If fromList Then fromList.removeItem(item)
		'try to add the item, if not able, readd
		If Not toList.addItem(item, data)
			If fromList
				if fromList.addItem(item) Then Return True

				'not able to add to "toList" but also not to "fromList"
				'so set veto and keep the item dragged
				triggerEvent.setVeto()
				return False
			endif
		EndIf


'method B
rem
		'-> this does not work as an "removal" might start things
		'   the "add" needs to know
		'also a list might only be able to add the object if that
		'got removed before (multi slots, or some other behaviour)

		'try to add the item, if able, remove from prior one
		local doMove:int = True
		If toList.addItem(item, data) and fromList
			if not fromList.removeItem(item) then triggerEvent.setVeto()
		endif
endrem

		Return True
	End Function


	'handle clicks on the up/down-buttons and inform others about changes
	Function onScrollWheel:Int( triggerEvent:TEventBase )
		Local list:TGUIListBase = TGUIListBase(triggerEvent.GetSender())
		Local value:Int = triggerEvent.GetData().getInt("value",0)
		If Not list Or value=0 Then Return False

		'emit event that the scroller position has changed
		local direction:string = ""
		select list._orientation
			case GUI_OBJECT_ORIENTATION_VERTICAL
				If value < 0 then direction = "up"
				If value > 0 then direction = "down"
			case GUI_OBJECT_ORIENTATION_HORIZONTAL
				If value < 0 then direction = "left"
				If value > 0 then direction = "right"
		End Select
		if direction <> "" then	EventManager.registerEvent(TEventSimple.Create("guiobject.onScrollPositionChanged", new TData.AddString("direction", direction).AddNumber("scrollAmount", 25), list))

		'set to accepted so that nobody else receives the event
		triggerEvent.SetAccepted(True)
	End Function


	'handle events from the connected scroller
	Function onScroll:Int( triggerEvent:TEventBase )
		local guiSender:TGUIObject = TGUIObject(triggerEvent.GetSender())
		if not guiSender then return False

		Local guiList:TGUIListBase = TGUIListBase(guiSender.GetParent("TGUIListBase"))
		If Not guiList Then Return False

		'do not allow scrolling if not enabled
		If Not guiList._scrollingEnabled Then Return False

		Local data:TData = triggerEvent.GetData()
		If Not data Then Return False


		'by default scroll by 2 pixels
		Local baseScrollSpeed:int = 2
		'the longer you pressed the mouse button, the "speedier" we get
		'1px per 100ms. Start speeding up after 500ms, limit to 20px per scroll
		baseScrollSpeed :+ Min(20, Max(0, MOUSEMANAGER.GetDownTime(1) - 500)/100.0)
		
		Local scrollAmount:Int = data.GetInt("scrollAmount", baseScrollSpeed)
		'this should be "calculate height and change amount"
		If data.GetString("direction") = "up" Then guiList.ScrollEntries(0, +scrollAmount)
		If data.GetString("direction") = "down" Then guiList.ScrollEntries(0, -scrollAmount)
		If data.GetString("direction") = "left" Then guiList.ScrollEntries(+scrollAmount,0)
		If data.GetString("direction") = "right" Then guiList.ScrollEntries(-scrollAmount,0)

		'maybe data was given in percents - so something like a
		'"scrollTo"-value
		If data.getString("changeType") = "percentage"
			local percentage:Float = data.GetFloat("percentage", 0)
			if guiSender = guiList.guiScrollerH
				guiList.SetScrollPercentageX(percentage)
			elseif guiSender = guiList.guiScrollerV
				guiList.SetScrollPercentageY(percentage)
			endif
		endif
		'from now on the user decides if he wants the end of the chat or stay inbetween
		guiList.scrollerUsed = True
	End Function


	'positive values scroll to top or left
	Method ScrollEntries(dx:float, dy:float)
		guiEntriesPanel.scroll(dx,dy)

		'refresh scroller values (for "progress bar" on the scroller)
		guiScrollerH.SetRelativeValue( GetScrollPercentageX() )
		guiScrollerV.SetRelativeValue( GetScrollPercentageY() )
	End Method


	Method GetScrollPercentageY:Float()
		return guiEntriesPanel.GetScrollPercentageY()
	End Method


	Method GetScrollPercentageX:Float()
		return guiEntriesPanel.GetScrollPercentageX()
	End Method


	Method SetScrollPercentageX:Float(percentage:float = 0.0)
		guiScrollerH.SetRelativeValue(percentage)
		return guiEntriesPanel.SetScrollPercentageX(percentage)
	End Method


	Method SetScrollPercentageY:Float(percentage:float = 0.0)
		guiScrollerH.SetRelativeValue(percentage)
		return guiEntriesPanel.SetScrollPercentageY(percentage)
	End Method


	Method ScrollToFirstItem()
		ScrollEntries(0, 0 )
	End Method


	Method ScrollToLastItem()
		Select _orientation
			case GUI_OBJECT_ORIENTATION_VERTICAL
				ScrollEntries(0, guiEntriesPanel.scrollLimit.GetY() )
			case GUI_OBJECT_ORIENTATION_HORIZONTAL
				ScrollEntries(guiEntriesPanel.scrollLimit.GetX(), 0 )
		End Select
	End Method


	'override default update-method
	Method Update:Int()
		Super.Update()

		'update all children (and therefore items of the guientriespanel)
		'now done by basic "Update" already
		'UpdateChildren()

		'enable/disable buttons of scrollers if they reached the
		'limits of the scrollable panel
		if guiScrollerH.hasOption(GUI_OBJECT_ENABLED)
			guiScrollerH.SetButtonStates(not guiEntriesPanel.ReachedLeftLimit(), not guiEntriesPanel.ReachedRightLimit())
		endif
		if guiScrollerV.hasOption(GUI_OBJECT_ENABLED)
			guiScrollerV.SetButtonStates(not guiEntriesPanel.ReachedTopLimit(), not guiEntriesPanel.ReachedBottomLimit())
		endif
				

		_mouseOverArea = THelper.MouseIn(GetScreenX(), GetScreenY(), rect.GetW(), rect.GetH())

		If autoHideScroller
			If _mouseOverArea
				guiScrollerV.hide()
				guiScrollerH.hide()
			Else
				guiScrollerV.show()
				guiScrollerH.show()
			EndIf
		EndIf
	End Method


	Method DrawBackground()
		If guiBackground
			guiBackground.Draw()
		Else
			Local oldCol:TColor = new TColor.Get()
			Local rect:TRectangle = new TRectangle.Init(guiEntriesPanel.GetScreenX(), guiEntriesPanel.GetScreenY(), Min(rect.GetW(), guiEntriesPanel.rect.GetW()), Min(rect.GetH(), guiEntriesPanel.rect.GetH()) )

			If _mouseOverArea
				backgroundColorHovered.setRGBA()
			Else
				backgroundColor.setRGBA()
			EndIf

			DrawRect(rect.GetX(), rect.GetY(), rect.GetW(), rect.GetH())

			oldCol.SetRGBA()
		EndIf
	End Method


	Method DrawContent()
		'
	End Method
	

	Method DrawDebug()
		If _debugMode
			SetAlpha 0.2
			Local rect:TRectangle = new TRectangle.Init(guiEntriesPanel.GetScreenX(), guiEntriesPanel.GetScreenY(), Min(rect.GetW(), guiEntriesPanel.rect.GetW()), Min(rect.GetH(), guiEntriesPanel.rect.GetH()) )
			DrawRect(rect.GetX(), rect.GetY(), rect.GetW(), rect.GetH())
			SetColor 255,0,0
			DrawRect(GetScreenX(), GetScreenY(), GetScreenWidth(), GetScreenHeight())
			SetColor 255,255,255
			SetAlpha 1.0

			Local oldCol:TColor = new TColor.Get()
			Local offset:Int = GetScreenY()
			For Local entry:TGUIListItem = EachIn entries
				'move entry's y position to current one
				SetAlpha 0.5
				DrawRect(	GetScreenX() + entry.rect.GetX() - 20,..
							GetScreenY() + entry.rect.GetY(),..
							entry.rect.GetW(),..
							entry.rect.GetH()-1..
						)
				SetAlpha 0.2
				SetColor 0,255,255
				DrawRect(0, offset+15, 40, 20 )
				SetAlpha 1.0
				DrawText(entry._id, 20, offset+15 )
				offset:+ entry.rect.GetH()


				SetAlpha 0.2
				SetColor 255,255,255
	'			SetColor 0,0,0
				SetAlpha 1.0
				DrawText(entry._id, GetScreenX()-20 + entry.rect.GetX(), GetScreenY() + entry.rect.GetY() )
				SetColor 255,255,255
			Next
			oldCol.SetRGBA()
		EndIf
	End Method
End Type



'basic list item
Type TGUIListItem Extends TGUIobject
	'how long until auto remove? (current value)
	Field lifetime:Float = Null
	'how long until auto remove? (initial value)
	Field initialLifetime:Float	= Null
	'how long until hiding (current value)
	Field showtime:Float = Null
	'how long until hiding (initial value)
	Field initialShowtime:Float	= Null
	'color of the displayed value
	Field valueColor:TColor	= new TColor

	Field positionNumber:Int = 0


    Method Create:TGUIListItem(pos:TVec2D=null, dimension:TVec2D=null, value:String="")
		'have a basic size (specify a dimension in your custom type)
		if not dimension then dimension = new TVec2D.Init(80,20)

		'limit this items to nothing - as soon as we parent it, it will
		'follow the parents limits
   		Super.CreateBase(pos, dimension, "")

		SetValue(value)

		'make dragable
		SetOption(GUI_OBJECT_DRAGABLE, True)

		GUIManager.add(Self)

		Return Self
	End Method


	Method Remove:Int()
		Super.Remove()

		'also remove itself from the list it may belong to
		'this adds the object back to the guimanager
		Local parent:TGUIobject = Self._parent
		If TGUIPanel(parent) Then parent = TGUIPanel(parent)._parent
		If TGUIScrollablePanel(parent) Then parent = TGUIScrollablePanel(parent)._parent
		If TGUIListBase(parent) Then TGUIListBase(parent).RemoveItem(Self)
		Return True
	End Method

	'override default
	Method onHit:Int(triggerEvent:TEventBase)
		Local data:TData = triggerEvent.GetData()
		If Not data Then Return False

		'only react on clicks with left mouse button
		If data.getInt("button") <> 1 Then Return False

		'we handled the click
		triggerEvent.SetAccepted(True)

		If isDragged()
			'instead of using auto-coordinates, we use the coord of the
			'mouseposition when the "hit" started
			'drop(new TVec2D.Init(data.getInt("x",-1), data.getInt("y",-1)))
			drop(MouseManager.GetClickPosition(1))
		Else
			'same for dragging
			'drag(new TVec2D.Init(data.getInt("x",-1), data.getInt("y",-1)))
			drag(MouseManager.GetClickPosition(1))
		EndIf
	End Method


	Method SetValueColor:Int(color:TColor=Null)
		valueColor = color
	End Method


	Method SetLifetime:Int(milliseconds:Int=Null)
		If milliseconds
			initialLifetime = milliseconds
			lifetime = Time.GetTimeGone() + milliseconds
		Else
			initialLifetime = Null
			lifetime = Null
		EndIf
	End Method


	Method Show()
		SetShowtime(initialShowtime)
		Super.Show()
	End Method


	Method SetShowtime:Int(milliseconds:Int=Null)
		If milliseconds
			InitialShowtime = milliseconds
			showtime = Time.GetTimeGone() + milliseconds
		Else
			InitialShowtime = Null
			showtime = Null
		EndIf
	End Method


	'override default update-method
	Method Update:Int()
		Super.Update()

		'if the item has a lifetime it will autoremove on death
		If lifetime And (Time.GetTimeGone() > lifetime) Then Return Remove()

		If showtime And isVisible()
			If (Time.GetTimeGone() > showtime) Then hide()
		EndIf
	End Method


	Method DrawContent()
		Local atPoint:TVec2D = GetScreenPos()
		Local draw:Int=True
		Local parent:TGUIobject = Null
		If Not(Self._flags & GUI_OBJECT_DRAGGED)
			parent = Self._parent
			If TGUIPanel(parent) Then parent = TGUIPanel(parent)._parent
			If TGUIListBase(parent) Then draw = TGUIListBase(parent).RestrictViewPort()
		EndIf
		If draw
			local oldCol:TColor = new TColor.Get()

			Local maxWidth:Int = GetParent().getContentScreenWidth() - rect.getX()

			'self.GetScreenX() and self.GetScreenY() include parents coordinate
			SetColor 0,0,0
			DrawRect(atPoint.GetX(), atPoint.GetY(), maxWidth, rect.getH())
			If Self._flags & GUI_OBJECT_DRAGGED
				SetColor 125,0,125
			Else
				SetColor 125,125,125
			EndIf
			DrawRect(atPoint.GetX() + 1, atPoint.GetY() + 1, maxWidth-2, rect.getH()-2)

			'hovered
			if mouseover
				SetBlend LightBlend
				SetAlpha 0.25 * GetAlpha()
				DrawRect(atPoint.GetX() + 1, atPoint.GetY() + 1, maxWidth-2, rect.getH()-2)
				SetAlpha 4 * GetAlpha()
				SetBlend AlphaBlend
			endif

			GetFont().drawBlock(value + " [" + Self._id + "]", atPoint.GetX() + 5, atPoint.GetY() + 2 + 0.5*(rect.getH() - GetFont().getHeight(value)), maxWidth-2, rect.GetH(), null, valueColor)

			oldCol.SetRGBA()
		EndIf
		If Not(Self._flags & GUI_OBJECT_DRAGGED) And TGUIListBase(parent)
			TGUIListBase(parent).ResetViewPort()
		EndIf
	End Method
End Type