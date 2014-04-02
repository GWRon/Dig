SuperStrict
Import "base.util.graphicsmanager.bmx"
Import "base.framework.app.bmx"
Import "base.framework.screen.bmx"

Type TGraphicalApp extends TApp
	'should the app do a CLS before rendering?
	Field autoCls:int = TRUE

	Method Prepare:int()
		local gm:TGraphicsManager = TGraphicsManager.GetInstance()
		gm.SetResolution(800, 600)
		gm.SetDesignedResolution(800, 600)
		gm.SetVSync(true)
		gm.SetHertz(0)

		gm.InitGraphics()
	End Method


	Method Update:Int()
		If KeyManager.IsHit(KEY_ESCAPE)
			exitApp = true
			print "exit now"
		endif

		local screen:TScreen = GetScreenManager().GetCurrent()
		If screen
			'update screen fader
			if screen.GetFadingEffect()
				screen.GetFadingEffect().Update()
			endif

			'update screen
			If Not screen.IsFading() Or screen.GetFadingEffect().allowScreenUpdate
				screen.Update()
			endif
		EndIf
	End Method


	Method Render:Int()
		if autoCls then Cls


		'render current screen
		local screen:TScreen = GetScreenManager().GetCurrent()
		If screen
			screen.RenderBackgroundLayers()
			screen.Render()
			screen.RenderForegroundLayers()

			screen.ExtraRender()

			'render a potential screen fader
			If screen.IsFading() Then screen.GetFadingEffect().Render()

			'draw debug on all (even fader)
			screen.DebugRender()
		EndIf

		RenderContent()

		'render debug info?
		If debugLevel > 0 then RenderDebug()

		'render mouse cursor etc
		RenderHUD()

		'flip render buffer onto screen
		GetGraphicsManager().Flip( GetDeltaTimer().HasLimitedFPS() )
	End Method


	Method RenderContent:Int()
		'
	End Method


	Method RenderHUD:Int()
		'
	End Method


	Method RenderDebug:Int()
		DrawText("FPS: "+GetDeltaTimer().currentFPS, 0, 0)
	End Method
End Type
