SuperStrict
Import "../../base.gfx.sprite.bmx"
Import "../../base.framework.screen.bmx"
Import "../../base.util.registry.bmx"
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
Import "../../base.gfx.gui.slider.bmx"
Import "../../base.gfx.gui.window.base.bmx"
Import "../../base.gfx.gui.window.modal.bmx"
Import "../../base.util.interpolation.bmx"
Import "app.screen.bmx"

Type TScreenMainMenu Extends TScreenMenuBase
	Field LogoFadeInFirstCall:Int = 0
	'store it so we can check for existence later on
	Global modalDialogue:TGUIModalWindow
	Global guiChat:TGUIChat
	Global sliderLabelH:TGUILabel
	Global sliderLabelV:TGUILabel


	Method Setup:Int()
		GuiManager.SetDefaultFont( GetBitmapFontManager().Get("Default", 14) )
		'buttons get a bold font
		TGUIButton.SetTypeFont( GetBitmapFontManager().Get("Default", 14, BOLDFONT) )


		Local button:TGUIButton = New TGUIButton.Create(New TVec2D.Init(20,20), New TVec2D.Init(130,-1), "Clickeriki?", Self.GetName())
		Local Input:TGUIInput = New TGUIInput.Create(New TVec2D.Init(20,55), New TVec2D.Init(130,-1), "empty", 20, Self.GetName())
		Input.SetOverlay("gfx_gui_icon_arrowRight")


		Local arrow:TGUIArrowButton = New TGUIArrowButton.Create(New TVec2D.Init(155,20), Null, "left", Self.GetName())
		Local checkbox:TGUICheckBox = New TGUICheckBox.Create(New TVec2D.Init(155,55), New TVec2D.Init(120, -1), "checkbox", Self.GetName())

		Local text:TGUITextbox = New TGUITextbox.Create(New TVec2D.Init(20,90), New TVec2D.Init(100,100), "I am a multiline textbox. Not pretty but nice to have.", Self.GetName())
		Local panel:TGUIPanel = New TGUIPanel.Create(New TVec2D.Init(20,250), New TVec2D.Init(150, 180), Self.GetName())
		panel.SetBackground( New TGUIBackgroundBox.Create(Null, Null) )
		panel.SetValue("press |b|space|/b| to go to next screen.~n~npress |b|T|/b| to add a toastmessage.")

		Local baseList:TGUIListBase = New TGUIListBase.Create(New TVec2D.Init(20,450), New TVec2D.Init(130,80), Self.GetName())
		'add some items to that list
		For Local i:Int = 1 To 10
			'base items do not have a size - so we have to give a manual one
			Local entry:TGUIListItem = New TGUIListItem.Create(Null, New TVec2D.Init(100, 20), "basetest "+i)
			'draw a beautiful rectangle as background
			entry._customDrawBackground = DrawListEntryBackground
			baseList.AddItem( entry )
		Next


		Local selectList:TGUISelectList = New TGUISelectList.Create(New TVec2D.Init(200,450), New TVec2D.Init(130,80), Self.GetName())
		'add some items to that list
		For Local i:Int = 1 To 5 '10
			'base items do not have a size - so we have to give a manual one
			Local entry:TGUISelectListItem = New TGUISelectListItem.Create(Null, New TVec2D.Init(100, 20), "selecttest "+i)
			'draw a beautiful rectangle as background
			entry._customDrawBackground = DrawListEntryBackground
			selectList.AddItem( entry )
		Next


		Local slotList:TGUISlotList = New TGUISlotList.Create(New TVec2D.Init(350,450), New TVec2D.Init(130,120), Self.GetName())
		slotList.SetSlotMinDimension(130, 20)
		'uncomment the following to make dropped items occupy the first
		'free slot
		'slotList.SetAutofillSlots(true)
		slotList.SetItemLimit(5) 'max 5 items
		'add some items to that list
		For Local i:Int = 1 To 3
			Local entry:TGUIListItem = New TGUIListItem.Create(Null, New TVec2D.Init(130,20), "slottest "+i)
			'draw a beautiful rectangle as background
			entry._customDrawBackground = DrawListEntryBackground
			slotList.SetItemToSlot( entry, i )
		Next

		'uncomment to have a simple image button
		'local imageButton:TGUIButton = new TGUIButton.Create(new TVec2D.Init(0,0), null, self.GetName())
		'imageButton.spriteName = "gfx_startscreen_logo"
		'imageButton.SetAutoSizeMode( TGUIButton.AUTO_SIZE_MODE_SPRITE )

		'a simple window
		Local window:TGuiWindowBase = New TGUIWindowBase.Create(New TVec2D.Init(590,250), New TVec2D.Init(200,150), Self.GetName())
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		window.SetCaptionArea(New TRectangle.Init(-1,5,-1,25))
		window.SetCaption("testwindow")
		window.SetValue("content")

Rem
		'a simple window
		local window2:TGuiWindowBase = new TGUIWindowBase.Create(new TVec2D.Init(50,50), new TVec2D.Init(500,300), self.GetName())
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		window2.SetCaptionArea(new TRectangle.Init(-1,5,-1,25))
		window2.SetCaption("testwindow")
		window2.SetValue(LoadText("anleitung.txt"))
endrem
		
		'a modal dialogue
		Local createModalDialogueButton:TGUIButton = New TGUIButton.Create(New TVec2D.Init(590,20), New TVec2D.Init(200,-1), "create modal window", Self.GetName())
		'handle clicking on that button
		EventManager.RegisterListenerFunction("guiobject.onclick", onClickCreateModalDialogue, createModalDialogueButton)



		Local dropdown:TGUIDropDown = New TGUIDropDown.Create(New TVec2D.Init(590,450), New TVec2D.Init(200,-1), "Sprache", 128, Self.GetName())
		'add some items to that list
		For Local i:Int = 1 To 10
			'base items do not have a size - so we have to give a manual one
			dropdown.AddItem( New TGUIDropDownItem.Create(Null, Null, "dropdown "+i) )
		Next


		guiChat = New TGUIChat.Create(New TVec2D.Init(200,300), New TVec2D.Init(300,120), Self.GetName())



		'horizontals
		Local slider:TGUISlider = New TGUISlider.Create(New TVec2D.Init(640,140), New TVec2D.Init(150,25), "40", "mainmenu")
		slider.SetValueRange(0,100)
		slider.steps = 0
		sliderLabelH = New TGUILabel.Create(New TVec2D.Init(640,227), "", TColor.clBlack, "mainmenu")

		Local slider2:TGUISlider = New TGUISlider.Create(New TVec2D.Init(640,110), New TVec2D.Init(150,25), "40", "mainmenu")
		slider2.SetValueRange(0,10)
		slider2.steps = 5
		slider2.SetRenderMode(TGUISlider.RENDERMODE_DISCRETE)

		Local slider2a:TGUISlider = New TGUISlider.Create(New TVec2D.Init(640,170), New TVec2D.Init(150,25), "40", "mainmenu")
		slider2a.SetValueRange(0,10)
		slider2a.steps = 5
		slider2a.SetValue(2)
		slider2a.SetDirection(TGUISlider.DIRECTION_LEFT)
		slider2a.SetRenderMode(TGUISlider.RENDERMODE_DISCRETE)

		Local slider2b:TGUISlider = New TGUISlider.Create(New TVec2D.Init(640,200), New TVec2D.Init(150,25), "40", "mainmenu")
		slider2b.SetValueRange(0,10)
		slider2b.steps = 5
		slider2b.SetDirection(TGUISlider.DIRECTION_LEFT)
		slider2b.SetRenderMode(TGUISlider.RENDERMODE_CONTINUOUS)

		
		Local slider2c:TGUISlider = New TGUISlider.Create(New TVec2D.Init(640,60), New TVec2D.Init(150,40), "40", "mainmenu")
		slider2c.SetValueRange(0,10)
		slider2c.steps = 5
		slider2c._gaugeOffset.SetY(12)
		slider2c.SetRenderMode(TGUISlider.RENDERMODE_CONTINUOUS)
		slider2c.SetDirection(TGUISlider.DIRECTION_RIGHT)

		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderH, slider)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderH, slider2)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderH, slider2a)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderH, slider2b)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderH, slider2c)

		'verticals
		'discrete up
		Local slider3:TGUISlider = New TGUISlider.Create(New TVec2D.Init(510,75), New TVec2D.Init(25,150), "40", "mainmenu")
		slider3.SetValueRange(0,10)
		slider3.SetValue(3)
		slider3.steps = 5
		slider3.SetRenderMode(TGUISlider.RENDERMODE_DISCRETE)
		slider3.SetDirection(TGUISlider.DIRECTION_UP)

		'smooth down
		Local slider3a:TGUISlider = New TGUISlider.Create(New TVec2D.Init(540,75), New TVec2D.Init(25,150), "40", "mainmenu")
		slider3a.SetValueRange(0,10)
		slider3a.steps = 0
		slider3a.SetDirection(TGUISlider.DIRECTION_UP)


		'discrete down
		Local slider3b:TGUISlider = New TGUISlider.Create(New TVec2D.Init(570,75), New TVec2D.Init(25,150), "40", "mainmenu")
		slider3b.SetValueRange(0,10)
		slider3b.steps = 5
		slider3b.SetRenderMode(TGUISlider.RENDERMODE_DISCRETE)
		slider3b.SetDirection(TGUISlider.DIRECTION_DOWN)

		'smooth down
		Local slider3c:TGUISlider = New TGUISlider.Create(New TVec2D.Init(600,75), New TVec2D.Init(25,150), "40", "mainmenu")
		slider3c.SetValueRange(0,10)
		slider3c.steps = 0
		slider3c.SetDirection(TGUISlider.DIRECTION_DOWN)


		sliderLabelV = New TGUILabel.Create(New TVec2D.Init(540,227), "", TColor.clBlack, "mainmenu")

		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderV, slider3)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderV, slider3a)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderV, slider3b)
		EventManager.registerListenerFunction( "guiobject.onChangeValue",	onChangeSliderV, slider3c)


		'register demo click listener - only listen to click events of
		'the "button" created above
'		EventManager.RegisterListenerFunction("guiobject.onclick", onClickMyButton, button)
'		EventManager.RegisterListenerFunction("guiobject.onclick", onClickOnAButton, "tguibutton")

		'we only listen to elements extending "TGUIObject"
		EventManager.RegisterListenerFunction("guiobject.onclick", onClickAGuiElement, "TGUIObject")
	End Method


	Function onChangeSliderV:Int( triggerEvent:TEventBase )
		Local slider:TGUISlider = TGUISlider(triggerEvent.GetSender())
		If Not slider Then Return False

		sliderLabelV.SetValue( slider.GetValue() )
	End Function


	Function onChangeSliderH:Int( triggerEvent:TEventBase )
		Local slider:TGUISlider = TGUISlider(triggerEvent.GetSender())
		If Not slider Then Return False

		sliderLabelH.SetValue( slider.GetValue() )
	End Function


	Function onClickCreateModalDialogue:Int(triggerEvent:TEventBase)
		modalDialogue = New TGUIModalWindow.Create(New TVec2D, New TVec2D.Init(400,250), "SYSTEM")
		modalDialogue.SetDialogueType(2)
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		modalDialogue.SetCaptionArea(New TRectangle.Init(-1,5,-1,25))
		modalDialogue.SetCaptionAndValue("test modal window", "test content")

		Print "created modal dialogue"
	End Function


	Function onClickAGuiElement:Int(triggerEvent:TEventBase)
		Local obj:TGUIObject = TGUIObject(triggerEvent.GetSender())
		Print "a gui element of type "+ obj.GetClassName() + " was clicked"
	End Function


	Function onClickOnAButton:Int(triggerEvent:TEventBase)
		'sender in this case is the gui object
		'cast as button to see if it is a button (or extends from one)
		Local button:TGUIButton = TGuiButton(triggerEvent.GetSender())
		'not interested in other widgets
		If Not button Then Return False

		Local mouseButton:Int = triggerEvent.GetData().GetInt("button")
		Print "a TGUIButton just got clicked with mouse button "+mouseButton
	End Function


	Function onClickMyButton:Int(triggerEvent:TEventBase)
		'sender in this case is the gui object
		'cast as button to see if it is a button (or extends from one)
		Local button:TGUIButton = TGuiButton(triggerEvent.GetSender())
		'not interested in other widgets
		If Not button Then Return False

		Local mouseButton:Int = triggerEvent.GetData().GetInt("button")
		Print "my button just got clicked with mouse button "+mouseButton
	End Function


	Function DrawListEntryBackground:Int(obj:TGUIObject)
		Local atPoint:TVec2D = obj.GetScreenPos()

		Local oldCol:TColor = New TColor.Get()

		Local maxWidth:Int = obj.GetParent().getContentScreenWidth() - obj.rect.getX()

		SetColor 0,0,0
		DrawRect(atPoint.GetX(), atPoint.GetY(), maxWidth, obj.rect.getH())
		If obj._flags & GUI_OBJECT_DRAGGED
			SetColor 125,0,125
		Else
			SetColor 125,125,125
		EndIf
		DrawRect(atPoint.GetX() + 1, atPoint.GetY() + 1, maxWidth-2, obj.rect.getH()-2)


		'hovered
		If obj.isHovered()
			SetBlend LightBlend
			SetAlpha 0.25 * GetAlpha()
			DrawRect(atPoint.GetX() + 1, atPoint.GetY() + 1, maxWidth-2, obj.rect.getH()-2)
			SetAlpha 4 * GetAlpha()
			SetBlend AlphaBlend
		EndIf

		oldCol.SetRGBA()

		'draw original widget background (eg. selected state for SelectList items)
		obj.DrawBackground()
	End Function
	

	Method PrepareStart:Int()
		Super.PrepareStart()
		LogoFadeInFirstCall = 0
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_SPACE)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("room1") )
		EndIf

		If KeyManager.IsHit(KEY_C)
			EventManager.triggerEvent( TEventSimple.Create( "chat.onAddEntry", New TData.AddNumber("senderID", 1).AddNumber("channels", guiChat.getChannelsFromText("text")).AddString("text", Rand(10000)) , guiChat ) )
		EndIf

		GuiManager.Update(Self.name)
	End Method


	Field logoAnimStart:Int = 0
	Field logoAnimTime:Int = 1500
	Field logoScale:Float = 0.0

	Method Render:Int()
		Super.Render()

		Local logo:TSprite = GetSpriteFromRegistry("gfx_startscreen_logo")
		If logo
			If logoAnimStart = 0 Then logoAnimStart = MilliSecs()
			logoScale = TInterpolation.BackOut(0.0, 1.0, Min(logoAnimTime, MilliSecs() - logoAnimStart), logoAnimTime)
			logoScale :* TInterpolation.BounceOut(0.0, 1.0, Min(logoAnimTime, MilliSecs() - logoAnimStart), logoAnimTime)

			Local oldAlpha:Float = GetAlpha()
			SetAlpha Float(TInterpolation.RegularOut(0.0, 1.0, Min(0.5*logoAnimTime, MilliSecs() - logoAnimStart), 0.5*logoAnimTime))

			logo.Draw( GraphicsWidth()/2, 150, -1, New TVec2D.Init(0.5, 0.5), logoScale)
			SetAlpha oldAlpha
		EndIf



		GuiManager.Draw(Self.name)
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

		guiList = New TGUIListBase.Create(New TVec2D.Init(0,0), New TVec2D.Init(GetContentScreenWidth(),GetContentScreenHeight()), limitState)
		guiList.setOption(GUI_OBJECT_ACCEPTS_DROP, False)
		guiList.SetAutoSortItems(False)
		guiList.SetAcceptDrop("")
		guiList.setParent(Self)
		guiList.SetAutoScroll(True)
		guiList.SetBackground(Null)

		Self.className = "TGUIChat"

		guiInput = New TGUIInput.Create(New TVec2D.Init(0, dimension.y),New TVec2D.Init(dimension.x,-1), "", 32, limitState)
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
		EventManager.triggerEvent( TEventSimple.Create( "chat.onAddEntry", New TData.AddNumber("senderID", 1).AddNumber("channels", sendToChannels).AddString("text",guiInput.value) , guiChat ) )

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
		Local senderColor:TColor= New TColor.CreateGrey(150)

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
		Create(Null,Null, text)
		SetLifetime(lifeTime)
		SetShowtime(lifeTime)
		SetSender(senderName, senderColor)
		SetValue(text)
		SetValueColor(textColor)

		Return Self
	End Method


    Method Create:TGUIChatEntry(pos:TVec2D=Null, dimension:TVec2D=Null, value:String="")
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
		Local move:TVec2D = New TVec2D.Init(0,0)
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
		If parentPanel
			maxWidth = parentPanel.GetContentScreenWidth() - rect.getX()
		Else
			maxWidth = GetParent().GetContentScreenWidth() - rect.getX()
		EndIf
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

		Local move:TVec2D = New TVec2D.Init(0,0)
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