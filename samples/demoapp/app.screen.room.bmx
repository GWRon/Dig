SuperStrict
Import "../../base.gfx.sprite.bmx"
Import "app.screen.bmx"



Type TScreenRoomBase extends TScreenInGame
    Field background:TSprite  'background, the image containing the whole room
	Field _contentArea:TRectangle


	Method Init:TScreenRoomBase(name:string)
		Super.Init(name)
		'limit content area
		_contentArea = new TRectangle.Init(20, 10, 760, 373)
		return self
	End Method


	Method ToString:string()
		return "TScreenRoomBase"
	End Method


	Method AdjustFadeEffects:Int(fromScreen:Tscreen, nextScreen:TScreen)
		'adjust fadein
		if fromScreen
			if TScreenRoomBase(fromScreen)
				fadeInEffect = new TScreenFaderClosingRects
				fadeInEffect.SetArea(_contentArea)
			else
				fadeInEffect = new TScreenFader
			endif
		endif
		if nextScreen
			if TScreenRoomBase(nextScreen)
				fadeOutEffect = new TScreenFaderClosingRects
				fadeOutEffect.SetArea(_contentArea)
			else
				fadeOutEffect = new TScreenFader
			endif
		endif
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_SPACE)
			if GetScreenManager().GetCurrent().name = "room1"
				FadeToScreen( GetScreenManager().Get("room2") )
			else
				FadeToScreen( GetScreenManager().Get("mainmenu") )
			endif
		Endif
	End Method


	Method Render:int()
		if background
			if _contentArea
				background.draw(_contentArea.GetX(), _contentArea.GetY())
			else
				background.draw(0, 0)
			endif
		else
			SetClsColor 100,100,100
			Cls
			SetClsColor 0,0,0
			DrawText(self.name,0,30)
		endif
	End Method
End Type