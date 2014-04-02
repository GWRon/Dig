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
Import "app.screen.bmx"

Type TScreenMainMenu extends TScreenMenuBase
	Field LogoFadeInFirstCall:int = 0


	Method Setup:Int()
		local button:TGUIButton = new TGUIButton.Create(new TPoint.Init(20,20), new TPoint.Init(100,-1), "Klick?", self.GetName())
		local input:TGUIInput = new TGUIInput.Create(new TPoint.Init(20,50), new TPoint.Init(100,-1), "leer", 20, self.GetName())
		input.SetOverlay("gfx_gui_overlay_player")

		local arrow:TGUIArrowButton = new TGUIArrowButton.Create(new TPoint.Init(120,20), null, "left", self.GetName())
		local checkbox:TGUICheckBox = new TGUICheckBox.Create(new TPoint.Init(120,50), null, true, "anklicken", self.GetName())

		local text:TGUITextbox = new TGUITextbox.Create(new TPoint.Init(20,90), new TPoint.Init(100,100), "Klick hier rein wenn es geht ich bin mehrzeilig.", self.GetName())
		local panel:TGUIPanel = new TGUIPanel.Create(new TPoint.Init(20,250), new TPoint.Init(100, 100), self.GetName())
		panel.SetBackground( new TGUIBackgroundBox.Create(null, null) )
		panel.SetValue("this panels text")
		panel.SetValue("this")
	End Method


	Method PrepareStart:Int()
		Super.PrepareStart()
		LogoFadeInFirstCall = 0
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_SPACE)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("room1") )
		Endif
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
	End Method
End Type