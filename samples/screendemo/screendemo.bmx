SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.gfx.sprite.particle.bmx"

Global MyApp:TMyApp = new TMyApp
MyApp.debugLevel = 1

Type TMyApp extends TGraphicalApp
	Field mouseCursorState:int = 0


	Method Prepare:int()
		super.Prepare()
		'we use a full screen background - so no cls needed
		autoCls = False

		'=== CREATE DEMO SCREENS ===
		GetScreenManager().Set(new TScreenMainMenu.Init("mainmenu"))
		GetScreenManager().Set(new TScreenInGame.Init("screen1"))
		GetScreenManager().Set(new TScreenInGame.Init("screen2"))
		'set the active one
		GetScreenManager().SetCurrent( GetScreenManager().Get("mainmenu") )
	End Method


	Method Update:Int()
		'run parental update (screen handling)
		Super.Update()

		'custom update things
	End Method


	Method RenderContent:Int()
		'custom render content
	End Method


	Method RenderHUD:Int()
		'=== DRAW MOUSE CURSOR ===
		'...
	End Method
End Type


Type TScreenInGame extends TScreen
	Field col:int = 0

	Method Init:TScreenInGame(name:string)
		Super.Init(name)

		col = 200
		if name = "screen1" then col = 100
		return self
	End Method


	Method Update:int()
		If Keymanager.IsHit(KEY_2)
			if name = "screen1"
				GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("screen2") )
			else
				GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("screen1") )
			endif
		ElseIf Keymanager.IsHit(KEY_3)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("mainmenu") )
		Endif
	End Method


	Method Render:int()
		SetClsColor col,col,col
		Cls
		SetClsColor 0,0,0

		DrawText("Ingame screen: " +self.name, 50,50)
		if name = "screen1"
			DrawText("Key ~q2~q to go to screen2", 50, 70)
		else
			DrawText("Key ~q2~q to go to screen1", 50, 70)
		endif
		DrawText("Key ~q3~q to go to mainmenu", 50, 90)

		'option 1 - there are some other inbuild render calls
		RenderInterface()
		'option 2 - a method named "ExtraRender" is called automatically
		'- just overwrite that method in your type
	End Method


	'option 1 - write a function which can get overwritten itself too
	Method RenderInterface:Int()
		'store old color - so we do not have to care for alpha
		'of fading screens or other modificators
		local col:TColor = new TColor.Get()
		SetColor 150,0,0
		Setalpha 0.5 * col.a 'half of the alpha of before
		DrawRect(0, 0, 100, GraphicsHeight())
		DrawRect(100, 0, Graphicswidth(), 50)
		col.SetRGBA()
	End Method


	'overwrite the function of TScreen - TGraphicalApp-Apps call this
	'automatically
	Method ExtraRender:int()
		'store old color - so we do not have to care for alpha
		'of fading screens or other modificators
		local col:TColor = new TColor.Get()
		SetColor 0,150,0
		Setalpha 0.5 * col.a 'half of the alpha of before
		DrawRect(GraphicsWidth()-100, 50, 100, GraphicsHeight()-50)
		DrawRect(100, GraphicsHeight()-50, Graphicswidth()-200, 50)
		col.SetRGBA()
	End Method

End Type


'base all outofgame-menus share
Type TScreenMenuBase extends TScreen

	Method Update:int()
		'
	End Method

	Method Render:int()
		'draw a background on all menus
		SetColor(100,0,50)
		DrawRect(0,0, GraphicsWidth(), GraphicsHeight())
		SetColor(255,255,255)
	End Method
End Type


Type TScreenMainMenu extends TScreenMenuBase
	Field smokeEmitter:TSpriteParticleEmitter

	Method Init:TScreenMainMenu(name:string)
		Super.Init(name)

		local smokeConfig:TData = new TData
'		smokeConfig.Add("sprite", GetSpriteFromRegistry("gfx_tex_smoke"))
		smokeConfig.AddNumber("velocityMin", 5.0)
		smokeConfig.AddNumber("velocityMax", 35.0)
		smokeConfig.AddNumber("lifeMin", 0.30)
		smokeConfig.AddNumber("lifeMax", 2.75)
		smokeConfig.AddNumber("scaleMin", 0.1)
		smokeConfig.AddNumber("scaleMax", 0.1)
		smokeConfig.AddNumber("angleMin", 176)
		smokeConfig.AddNumber("angleMax", 184)
		smokeConfig.AddNumber("xRange", 2)
		smokeConfig.AddNumber("yRange", 2)

		local emitterConfig:TData = new TData
		emitterConfig.Add("area", new TRectangle.Init(69, 335, 0, 0))
		emitterConfig.AddNumber("particleLimit", 100)
		emitterConfig.AddNumber("spawnEveryMin", 0.35)
		emitterConfig.AddNumber("spawnEveryMax", 0.60)

		smokeEmitter = new TSpriteParticleEmitter.Init(emitterConfig, smokeConfig)

		return self
	End Method


	Method Render:int()
		'also call the render-function of TScreenMenuBase
		Super.Render()

		smokeEmitter.Draw()

		DrawText("Welcome", 50, 50)
		DrawText("Key ~q1~q to go to screen1", 50, 70)
	EndMethod

	Method Update:int()
		If Keymanager.IsHit(KEY_1)
			GetScreenManager().GetCurrent().FadeToScreen( GetScreenManager().Get("screen1") )
		EndIf

		smokeEmitter.Update()
	End Method
End Type



'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()

