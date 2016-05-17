SuperStrict
Import "../../base.gfx.sprite.bmx"
Import "../../base.framework.screen.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.gfx.gui.button.bmx"
Import "../../base.gfx.gui.arrowbutton.bmx"
Import "../../base.gfx.gui.backgroundbox.bmx"
Import "../../base.gfx.gui.checkbox.bmx"
Import "../../base.gfx.gui.input.bmx"
Import "../../base.gfx.gui.textbox.bmx"
Import "../../base.gfx.gui.panel.bmx"
Import "../../base.gfx.gui.list.base.bmx"
Import "../../base.gfx.gui.list.selectlist.bmx"
Import "../../base.gfx.gui.list.slotlist.bmx"
Import "../../base.gfx.gui.dropdown.bmx"
Import "../../base.gfx.gui.window.base.bmx"
Import "../../base.gfx.gui.window.modal.bmx"
Import "../../base.util.interpolation.bmx"


Type TScreenGui extends TScreen
	'store it so we can check for existence later on
	global modalDialogue:TGUIModalWindow

	Method Setup:Int()
		GuiManager.SetDefaultFont( GetBitmapFontManager().Get("Default", 14) )
		'buttons get a bold font
		TGUIButton.SetTypeFont( GetBitmapFontManager().Get("Default", 14, BOLDFONT) )


		local guiRowX1:int = 70

		local button:TGUIButton = new TGUIButton.Create(new TVec2D.Init(guiRowX1, 20), new TVec2D.Init(130,-1), "Clickeriki?", self.GetName())
		local input:TGUIInput = new TGUIInput.Create(new TVec2D.Init(guiRowX1, 55), new TVec2D.Init(130,-1), "empty", 20, self.GetName())
		input.SetOverlay("gfx_gui_icon_arrowRight")


		local dropdown:TGUIDropDown = new TGUIDropDown.Create(new TVec2D.Init(guiRowX1,90), new TVec2D.Init(130,-1), "Sprache", 128, self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			dropdown.AddItem( new TGUIDropDownItem.Create(null, null, "dropdown "+i) )
		Next


		local arrow:TGUIArrowButton = new TGUIArrowButton.Create(new TVec2D.Init(guiRowX1, 125), null, "left", self.GetName())
		local checkbox:TGUICheckBox = new TGUICheckBox.Create(new TVec2D.Init(guiRowX1, 160), new TVec2D.Init(130, -1), "checkbox label", self.GetName())

		local text:TGUITextbox = new TGUITextbox.Create(new TVec2D.Init(guiRowX1, 195), new TVec2D.Init(130, 70), "I am a multiline textbox. Not pretty but nice to have.", self.GetName())
		local panel:TGUIPanel = new TGUIPanel.Create(new TVec2D.Init(guiRowX1, 275), new TVec2D.Init(130, 120), self.GetName())
		panel.SetBackground( new TGUIBackgroundBox.Create(null, null) )
		panel.SetValue("press |b|space|/b| to display the next gui screen.")


		local baseList:TGUIListBase = new TGUIListBase.Create(new TVec2D.Init(guiRowX1, 450), new TVec2D.Init(130,80), self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			baseList.AddItem( new TGUIListItem.Create(null, new TVec2D.Init(100, 20), "basetest "+i) )
		Next


		local selectList:TGUISelectList = new TGUISelectList.Create(new TVec2D.Init(200,450), new TVec2D.Init(130,80), self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			selectList.AddItem( new TGUISelectListItem.Create(null, null, "selecttest "+i) )
		Next


		local slotList:TGUISlotList = new TGUISlotList.Create(new TVec2D.Init(350,450), new TVec2D.Init(130,120), self.GetName())
		slotList.SetSlotMinDimension(130, 20)
		'uncomment the following to make dropped items occupy the first
		'free slot
		'slotList.SetAutofillSlots(true)
		slotList.SetItemLimit(5) 'max 5 items
		'add some items to that list
		for local i:int = 1 to 3
			slotList.SetItemToSlot( new TGUIListItem.Create(null, new TVec2D.Init(130,20), "slottest "+i), i )
		Next

		'uncomment to have a simple image button
		'local imageButton:TGUIButton = new TGUIButton.Create(new TVec2D.Init(0,0), null, self.GetName())
		'imageButton.spriteName = "gfx_startscreen_logo"
		'imageButton.SetAutoSizeMode( TGUIButton.AUTO_SIZE_MODE_SPRITE )

		'a simple window
		local window:TGuiWindowBase = new TGUIWindowBase.Create(new TVec2D.Init(550,200), new TVec2D.Init(200,150), self.GetName())
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		window.SetCaptionArea(new TRectangle.Init(-1,5,-1,25))
		window.SetCaption("testwindow")
		window.SetValue("content")

	
		'a modal dialogue
		local createModalDialogueButton:TGUIButton = new TGUIButton.Create(new TVec2D.Init(610,20), new TVec2D.Init(180,-1), "create modal window", self.GetName())
		'handle clicking on that button
		EventManager.RegisterListenerFunction("guiobject.onclick", onClickCreateModalDialogue, createModalDialogueButton)


'		local chat:TGUIChat = new TGUIChat.Create(new TVec2D.Init(200,300), new TVec2D.Init(300,120), self.GetName())

		'register demo click listener - only listen to click events of
		'the "button" created above
		'EventManager.RegisterListenerFunction("guiobject.onclick", onClickMyButton, button)
		'EventManager.RegisterListenerFunction("guiobject.onclick", onClickAGuiElement)
		'EventManager.RegisterListenerFunction("guiobject.onclick", onClickOnAButton, "tguibutton")
	End Method


	Function onClickCreateModalDialogue:Int(triggerEvent:TEventBase)
		modalDialogue = new TGUIModalWindow.Create(new TVec2D, new TVec2D.Init(400,250), "SYSTEM")
		modalDialogue.SetDialogueType(2)
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		modalDialogue.SetCaptionArea(new TRectangle.Init(-1,5,-1,25))
		modalDialogue.SetCaptionAndValue("test modal window", "test content")

		print "created modal dialogue"
	End Function


	Function onClickAGuiElement:Int(triggerEvent:TEventBase)
		local obj:TGUIObject = TGUIObject(triggerEvent.GetSender())
		print "a gui element of type "+ obj.GetClassName() + " was clicked"
	End Function


	Function onClickOnAButton:Int(triggerEvent:TEventBase)
		'sender in this case is the gui object
		'cast as button to see if it is a button (or extends from one)
		local button:TGUIButton = TGuiButton(triggerEvent.GetSender())
		'not interested in other widgets
		if not button then return FALSE

		local mouseButton:Int = triggerEvent.GetData().GetInt("button")
		print "a TGUIButton just got clicked with mouse button "+mouseButton
	End Function


	Function onClickMyButton:Int(triggerEvent:TEventBase)
		'sender in this case is the gui object
		'cast as button to see if it is a button (or extends from one)
		local button:TGUIButton = TGuiButton(triggerEvent.GetSender())
		'not interested in other widgets
		if not button then return FALSE

		local mouseButton:Int = triggerEvent.GetData().GetInt("button")
		print "my button just got clicked with mouse button "+mouseButton
	End Function


	Method PrepareStart:Int()
		Super.PrepareStart()
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_SPACE)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("room1") )
		Endif

		GuiManager.Update(self.name)
	End Method
	

	Method Render:int()
		'draw a background on all menus
		SetColor(255,255,255)
		GetSpriteFromRegistry("gfx_startscreen").Draw(0,0)

		GuiManager.Draw(self.name)

		local centerY:int = 5
		GetBitmapFont("default").DrawBlock("Button:", 10, 20 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("Input:", 10, 55 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("DropDown:", 10, 90 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("Arrow:", 10, 125 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("Checkbox:", 10, 160 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("Multiline Textbox:", 10, 195 + centerY, 60, 35)
		GetBitmapFont("default").DrawBlock("Panel:", 10, 275 + centerY, 60, 35)
	End Method
End Type








Type TGUIChat Extends TGUIPanel
	Field _defaultTextColor:TColor = TColor.Create(0,0,0)
	Field _defaultHideEntryTime:Int = Null
	'bitmask of channels the chat listens to
	Field _channels:Int = 0
	Field guiList:TGUIListBase = Null
	Field guiInput:TGUIInput = Null
	'is the input is inside the chatbox or absolute
	Field guiInputPositionRelative:Int = 0
	Field guiInputHistory:TList	= CreateList()
	Field keepInputActive:Int = True

	'time when again allowed to send
	Global antiSpamTimer:Int = 0
	Global antiSpamTime:Int	= 100


	Method Create:TGUIChat(pos:TVec2D, dimension:TVec2D, limitState:String = "")
		Super.Create(pos, dimension, limitState)

		guiList = New TGUIListBase.Create(new TVec2D.Init(0,0), new TVec2D.Init(GetContentScreenWidth(),GetContentScreenHeight()), limitState)
		guiList.setOption(GUI_OBJECT_ACCEPTS_DROP, False)
		guiList.SetAutoSortItems(False)
		guiList.SetAcceptDrop("")
		guiList.setParent(Self)
		guiList.SetAutoScroll(True)
		guiList.SetBackground(Null)

		guiInput = New TGUIInput.Create(new TVec2D.Init(0, dimension.y),new TVec2D.Init(dimension.x,-1), "", 32, limitState)
		guiInput.setParent(Self)

		'resize base and move child elements
		resize(dimension.GetX(), dimension.GetY())

		'by default all chats want to list private messages and system announcements
		setListenToChannel(1, True)
		setListenToChannel(2, True)
		setListenToChannel(4, True)

		'register events
		'- observe text changes in our input field
		EventManager.registerListenerFunction( "guiobject.onChange", Self.onInputChange, Self.guiInput )
		'- observe wishes to add a new chat entry - listen to all sources
		EventManager.registerListenerMethod( "chat.onAddEntry", Self, "onAddEntry" )

		GUIManager.Add( Self )

		Return Self
	End Method


	'returns boolean whether chat listens to a channel
	Method isListeningToChannel:Int(channel:Int)
		Return Self._channels & channel
	End Method


	Method setListenToChannel(channel:Int, enable:Int=True)
		If enable
			Self._channels :| channel
		Else
			Self._channels :& ~channel
		EndIf
	End Method


	Method SetDefaultHideEntryTime(milliseconds:Int=Null)
		Self._defaultHideEntryTime = milliseconds
	End Method


	Method SetDefaultTextColor(color:TColor)
		Self._defaultTextColor = color
	End Method


	Function onInputChange:Int( triggerEvent:TEventBase )
		Local guiInput:TGUIInput = TGUIInput(triggerEvent.getSender())
		If guiInput = Null Then Return False

		Local guiChat:TGUIChat = TGUIChat(guiInput._parent)
		If guiChat = Null Then Return False

		'skip empty text
		If guiInput.value.Trim() = "" Then Return False

		'emit event : chats should get a new line
		'- step A) is to get what channels we want to announce to
		Local sendToChannels:Int = guiChat.getChannelsFromText(guiInput.value)
		'- step B) is emitting the event "for all"
		'  (the listeners have to handle if they want or ignore the line
		EventManager.triggerEvent( TEventSimple.Create( "chat.onAddEntry", new TData.AddNumber("senderID", 1).AddNumber("channels", sendToChannels).AddString("text",guiInput.value) , guiChat ) )

		'avoid getting the enter-key registered multiple times
		'which leads to "flickering"
		KEYMANAGER.blockKey(KEY_ENTER, 250) 'block for 100ms

		'trigger antiSpam
		guiChat.antiSpamTimer = Time.GetTimeGone() + guiChat.antiSpamTime

		If guiChat.guiInputHistory.last() <> guiInput.value
			guiChat.guiInputHistory.AddLast(guiInput.value)
		EndIf

		'reset input field
		guiInput.SetValue("")
	End Function


	Method onAddEntry:Int( triggerEvent:TEventBase )
		Local guiChat:TGUIChat = TGUIChat(triggerEvent.getReceiver())
		'if event has a specific receiver and this is not a chat - we are not interested
		If triggerEvent.getReceiver() And Not guiChat Then Return False
		'found a chat - but it is another chat
		If guiChat And guiChat <> Self Then Return False

		'here we could add code to exlude certain other chat channels
		Local sendToChannels:Int = triggerEvent.getData().getInt("channels", 0)
		If Self.isListeningToChannel(sendToChannels)
			Self.AddEntryFromData( triggerEvent.getData() )
		Else
			Print "onAddEntry - unknown channel, not interested"
		EndIf
	End Method


	Function getChannelsFromText:Int(text:String)
		Local sendToChannels:Int = 0 'by default send to no channel
		Select getSpecialCommandFromText(text)
			Case 1
				sendToChannels :| 1
			Default
				sendToChannels :| 2
		End Select
		Return SendToChannels
	End Function


	Function getSpecialCommandFromText:Int(text:String)
		text = text.Trim()

		If Left( text,1 ) <> "/" Then Return 0

		Local spacePos:Int = Instr(text, " ")
		Local commandString:String = Mid(text, 2, spacePos-2 ).toLower()
		Local payload:String = Right(text, text.length -spacePos)

		Select commandString
			Case "fluestern", "whisper", "w"
				'local spacePos:int = instr(payload, " ")
				'local target:string = Mid(payload, 1, spacePos-1 ).toLower()
				'local message:string = Right(payload, payload.length -spacePos)
				'print "whisper to: " + "-"+target+"-"
				'print "whisper msg:" + message
				Return 1
			Default
				'print "command: -"+commandString+"-"
				'print "payload: -"+payload+"-"
				Return 0
		End Select
	End Function


	Method AddEntry(entry:TGUIListItem)
		guiList.AddItem(entry)
	End Method


	Method AddEntryFromData( data:TData )
		Local text:String		= data.getString("text", "")
		Local textColor:TColor	= TColor( data.get("textColor", TColor.clWhite) )
		Local senderID:Int		= data.getInt("senderID", 0)
		Local senderName:String	= "test"
		Local senderColor:TColor= new TColor.CreateGrey(150)

		'finally add to the chat box
		Local entry:TGUIChatEntry = New TGUIChatEntry.CreateSimple(text, textColor, senderName, senderColor, Null )
		'if the default is "null" then no hiding will take place
		entry.SetShowtime( _defaultHideEntryTime )
		AddEntry( entry )
	End Method


	Method SetPadding:Int(top:Float,Left:Float,bottom:Float,Right:Float)
		GetPadding().setTLBR(top,Left,bottom,Right)
		resize()
	End Method


	'override resize and add minSize-support
	Method Resize(w:Float = 0, h:Float = 0)
		Super.Resize(w, h)

		'background covers whole area, so resize it
		If guiBackground Then guiBackground.resize(rect.getW(), rect.getH())

		Local subtractInputHeight:Float = 0.0
		'move and resize input field to the bottom
		If guiInput And Not guiInput.hasOption(GUI_OBJECT_POSITIONABSOLUTE)
			guiInput.resize(GetContentScreenWidth(),Null)
			guiInput.rect.position.setXY(0, GetContentScreenHeight() - guiInput.GetScreenHeight())
			subtractInputHeight = guiInput.GetScreenHeight()
		EndIf

		'move and resize the listbox (subtract input if needed)
		If guiList
			guiList.resize(GetContentScreenWidth(), GetContentScreenHeight() - subtractInputHeight)
		EndIf
	End Method


	'override default update-method
	Method Update:Int()
		Super.Update()

		'show items again if somone hovers over the list (-> reset timer)
		If guiList._mouseOverArea
			For Local entry:TGuiObject = EachIn guiList.entries
				entry.show()
			Next
		EndIf
	End Method
End Type




Type TGUIChatEntry Extends TGUIListItem
	Field paddingBottom:Int	= 5


	Method CreateSimple:TGUIChatEntry(text:String, textColor:TColor, senderName:String, senderColor:TColor, lifetime:Int=Null)
		Create(null,null, text)
		SetLifetime(lifeTime)
		SetShowtime(lifeTime)
		SetSender(senderName, senderColor)
		SetValue(text)
		SetValueColor(textColor)

		Return Self
	End Method


    Method Create:TGUIChatEntry(pos:TVec2D=null, dimension:TVec2D=null, value:String="")
		'no "super.Create..." as we do not need events and dragable and...
   		Super.CreateBase(pos, dimension, "")

		Resize(GetDimension().GetX(), GetDimension().GetY())
		SetValue(value)
		SetLifetime( 1000 )
		SetShowtime( 1000 )

		GUIManager.add(Self)

		Return Self
	End Method


	Method getDimension:TVec2D()
		Local move:TVec2D = new TVec2D.Init(0,0)
		If Data.getString("senderName",Null)
			Local senderColor:TColor = TColor(Data.get("senderColor"))
			If Not senderColor Then senderColor = TColor.Create(0,0,0)
			move = GetBitmapFontManager().baseFont.drawStyled(Data.getString("senderName", "")+":", Self.getScreenX(), Self.getScreenY(), TColor.clBlack, 2, 0)
			'move the x so we get space between name and text
			'move the y point 1 pixel as bold fonts are "higher"
			move.setXY( move.x+5, 1)
		EndIf
		'available width is parentsDimension minus startingpoint
		Local parentPanel:TGUIScrollablePanel = TGUIScrollablePanel(GetParent("tguiscrollablepanel"))
		Local maxWidth:Int
		if parentPanel
			maxWidth = parentPanel.GetContentScreenWidth() - rect.getX()
		else
			maxWidth = GetParent().GetContentScreenWidth() - rect.getX()
		endif
		Local maxHeight:Int = 2000 'more than 2000 pixel is a really long text

		Local dimension:TVec2D = GetBitmapFontManager().baseFont.drawBlock(GetValue(), getScreenX()+move.x, getScreenY()+move.y, maxWidth-move.X, maxHeight, Null, Null, 2, 0)

		'add padding
		dimension.AddXY(0, paddingBottom)

		'set current size and refresh scroll limits of list
		'but only if something changed (eg. first time or content changed)
		If rect.getW() <> dimension.getX() Or rect.getH() <> dimension.getY()
			'resize item
			Resize(dimension.getX(), dimension.getY())
			'recalculate item positions and scroll limits
'			local list:TGUIListBase = TGUIListBase(self.getParent("tguilistbase"))
'			if list then list.RecalculateElements()
		EndIf

		Return dimension
	End Method


	Method SetSender:Int(senderName:String=Null, senderColor:TColor=Null)
		If senderName Then Data.AddString("senderName", senderName)
		If senderColor Then Data.Add("senderColor", senderColor)
	End Method


	Method getParentWidth:Float(parentClassName:String="toplevelparent")
		If Not Self._parent Then Return Self.rect.getW()
		Return Self.getParent(parentClassName).rect.getW()
	End Method


	Method getParentHeight:Float(parentClassName:String="toplevelparent")
		If Not Self._parent Then Return Self.rect.getH()
		Return Self.getParent(parentClassName).rect.getH()
	End Method


	Method DrawContent()
		If Self.showtime <> Null Then SetAlpha Float(Self.showtime - Time.GetTimeGone())/500.0
		'available width is parentsDimension minus startingpoint
		Local parentPanel:TGUIScrollablePanel = TGUIScrollablePanel(Self.getParent("tguiscrollablepanel"))
		Local maxWidth:Int = parentPanel.getContentScreenWidth()-Self.rect.getX()

		'local maxWidth:int = self.getParentWidth("tguiscrollablepanel")-self.rect.getX()
		Local maxHeight:Int = 2000 'more than 2000 pixel is a really long text

		Local move:TVec2D = new TVec2D.Init(0,0)
		Local senderColor:TColor = TColor(Self.Data.get("senderColor"))
		If Not senderColor Then senderColor = TColor.Create(0,0,0)
		move = GetBitmapFontManager().baseFont.drawStyled(Self.Data.getString("senderName", "")+":", Self.getScreenX(), Self.getScreenY(), senderColor, 2, 1)
		'move the x so we get space between name and text
		'move the y point 1 pixel as bold fonts are "higher"
		move.setXY( move.x+5, 1)
		GetBitmapFontManager().baseFont.drawBlock(GetValue(), getScreenX()+move.x, getScreenY()+move.y, maxWidth-move.X, maxHeight, Null, valueColor, 2, 1, 0.5)

		SetAlpha 1.0
	End Method
End Type
