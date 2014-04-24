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
Import "../../base.gfx.gui.dropdown.bmx"
Import "../../base.gfx.gui.window.base.bmx"
Import "../../base.gfx.gui.window.modal.bmx"
Import "app.screen.bmx"

Type TScreenMainMenu extends TScreenMenuBase
	Field LogoFadeInFirstCall:int = 0
	'store it so we can check for existence later on
	global modalDialogue:TGUIModalWindow

	Method Setup:Int()
		local button:TGUIButton = new TGUIButton.Create(new TPoint.Init(20,20), new TPoint.Init(130,-1), "Clickeriki?", self.GetName())
		local input:TGUIInput = new TGUIInput.Create(new TPoint.Init(20,55), new TPoint.Init(130,-1), "empty", 20, self.GetName())
		input.SetOverlay("gfx_gui_icon_arrowRight")

		local arrow:TGUIArrowButton = new TGUIArrowButton.Create(new TPoint.Init(155,20), null, "left", self.GetName())
		local checkbox:TGUICheckBox = new TGUICheckBox.Create(new TPoint.Init(155,55), null, true, "checkbox", self.GetName())

		local text:TGUITextbox = new TGUITextbox.Create(new TPoint.Init(20,90), new TPoint.Init(100,100), "I am a multiline textbox. Not pretty but nice to have.", self.GetName())
		local panel:TGUIPanel = new TGUIPanel.Create(new TPoint.Init(20,250), new TPoint.Init(120, 150), self.GetName())
		panel.SetBackground( new TGUIBackgroundBox.Create(null, null) )
		panel.SetValue("press ~qspace~q to go to next screen")

		local baseList:TGUIListBase = new TGUIListBase.Create(new TPoint.Init(20,450), new TPoint.Init(130,80), self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			baseList.AddItem( new TGUIListItem.Create(null, new TPoint.Init(100, 20), "basetest "+i) )
		Next

		local selectList:TGUISelectList = new TGUISelectList.Create(new TPoint.Init(200,450), new TPoint.Init(130,80), self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			selectList.AddItem( new TGUISelectListItem.Create(null, null, "selecttest "+i) )
		Next

		'a simple window
		local window:TGuiWindowBase = new TGUIWindowBase.Create(new TPoint.Init(550,200), new TPoint.Init(200,150), self.GetName())
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		window.SetCaptionArea(new TRectangle.Init(-1,5,-1,25))
		window.SetCaption("testwindow")
		window.SetValue("content")


		local createModalDialogueButton:TGUIButton = new TGUIButton.Create(new TPoint.Init(610,20), new TPoint.Init(180,-1), "create modal window", self.GetName())
		'handle clicking on that button
		EventManager.RegisterListenerFunction("guiobject.onclick", onClickCreateModalDialogue, createModalDialogueButton)



		local dropdown:TGUIDropDown = new TGUIDropDown.Create(new TPoint.Init(380,450), new TPoint.Init(130,80), self.GetName())
		'add some items to that list
		for local i:int = 1 to 10
			'base items do not have a size - so we have to give a manual one
			dropdown.AddItem( new TGUIDropDownItem.Create(null, null, "dropdown "+i) )
		Next
		'register demo click listener - only listen to click events of
		'the "button" created above
'		EventManager.RegisterListenerFunction("guiobject.onclick", onClickMyButton, button)
'		EventManager.RegisterListenerFunction("guiobject.onclick", onClickAGuiElement)
'		EventManager.RegisterListenerFunction("guiobject.onclick", onClickOnAButton, "tguibutton")
	End Method


	Function onClickCreateModalDialogue:Int(triggerEvent:TEventBase)
		modalDialogue = new TGUIModalWindow.Create(new TPoint, new TPoint.Init(400,250), "SYSTEM")
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
		LogoFadeInFirstCall = 0
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_SPACE)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("room1") )
		Endif

		GuiManager.Update(self.name)
	End Method


	Method Render:int()
		Super.Render()

		local logo:TSprite = GetSpriteFromRegistry("gfx_startscreen_logo")
		if logo
			local oldAlpha:float = GetAlpha()
			If LogoFadeInFirstCall = 0 Then LogoFadeInFirstCall = MilliSecs()
			SetAlpha oldAlpha * ((MilliSecs() - LogoFadeInFirstCall) / 750.0)
			logo.Draw( GraphicsWidth()/2 - logo.area.GetW() / 2, 100)
			SetAlpha oldAlpha
		Endif

		GuiManager.Draw(self.name)
	End Method
End Type