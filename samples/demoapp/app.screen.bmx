SuperStrict
Import "../../base.framework.screen.bmx"
Import "../../base.util.input.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.spriteloader.bmx"


Type TScreenInGame extends TScreen
	Field col:int = 0

	Method Init:TScreenInGame(name:string)
		Super.Init(name)

		col = 200
		if name = "main" then col = 100
		return self
	End Method


	Method Update:int()
		'
	End Method


	Method Render:int()
		'
	End Method
End Type




Type TScreenMenuBase extends TScreen

	Method Update:int()
		'
	End Method

	Method Render:int()
		'draw a background on all menus
		SetColor(255,255,255)
		GetSpriteFromRegistry("gfx_startscreen").Draw(0,0)
	End Method
End Type