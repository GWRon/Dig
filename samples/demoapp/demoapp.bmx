SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"

'game specific
Import "app.screen.mainmenu.bmx"
Import "app.screen.room.bmx"

Global MyApp:TMyApp = new TMyApp
MyApp.debugLevel = 1

Type TMyApp extends TGraphicalApp
	Field mouseCursorState:int = 0


	Method Prepare:int()
		super.Prepare()
		'we use a full screen background - so no cls needed
		autoCls = False

		'=== LOAD RESOURCES ===
		local registryLoader:TRegistryLoader = new TRegistryLoader
		'if loading from a "parent directory" - state this here
		'-> all resources can get loaded with "relative paths"
		'registryLoader.baseURI = "../"

		'afterwards we can display background images and cursors
		'"TRUE" indicates that the content has to get loaded immediately
		registryLoader.LoadFromXML("res/config/startup.xml", TRUE)

		registryLoader.LoadFromXML("res/config/resources.xml")

		'set a basic font ?
		'SetImageFont(LoadImageFont("../res/fonts/Vera.ttf", 12))

		'=== CREATE DEMO SCREENS ===
		GetScreenManager().Set(new TScreenMainMenu.Init("mainmenu"))
		GetScreenManager().Set(new TScreenRoomBase.Init("room1"))
		GetScreenManager().Set(new TScreenRoomBase.Init("room2"))
		GetScreenManager().SetCurrent( GetScreenManager().Get("mainmenu") )
	End Method


	Method Update:Int()
		'fetch and cache mouse and keyboard states for this cycle
		GUIManager.StartUpdates()

		'run parental update (screen handling)
		Super.Update()

		'=== UPDATE GUI ===
		'system wide gui elements
		GuiManager.Update("SYSTEM")

		'check if new resources have to get loaded
		TRegistryUnloadedResourceCollection.GetInstance().Update()

		'reset modal window states
		GUIManager.EndUpdates()
	End Method


	Method RenderContent:Int()
		'=== RENDER GUI ===
		'system wide gui elements
		GuiManager.Draw("SYSTEM")
	End Method


	Method RenderLoadingResourcesInformation:Int()
		'do nothing if there is nothing to load
		if TRegistryUnloadedResourceCollection.GetInstance().FinishedLoading() then return TRUE

		'reduce instance requests
		local RURC:TRegistryUnloadedResourceCollection = TRegistryUnloadedResourceCollection.GetInstance()


		SetAlpha 0.2
		SetColor 50,0,0
		DrawRect(0, GraphicsHeight() - 20, GraphicsWidth(), 20)
		SetAlpha 1.0
		SetColor 255,255,255
		DrawText("Loading: "+RURC.loadedCount+"/"+RURC.toLoadCount+"  "+String(RURC.loadedLog.Last()), 0, 580)
	End Method


	Method RenderHUD:Int()
		'=== DRAW RESOURCEL LOADING INFORMATION ===
		'if there is a resource loading currently - display information
		RenderLoadingResourcesInformation()


		'=== DRAW MOUSE CURSOR ===
		'default pointer
		If mouseCursorState = 0 Then GetSpriteFromRegistry("gfx_mousecursor").Draw(MouseManager.x-9, MouseManager.y-2, 0)
		'open hand
		If mouseCursorState = 1 Then GetSpriteFromRegistry("gfx_mousecursor").Draw(MouseManager.x-11, MouseManager.y-8, 1)
		'grabbing hand
		If mouseCursorState = 2 Then GetSpriteFromRegistry("gfx_mousecursor").Draw(MouseManager.x-11, MouseManager.y-16, 2)
	End Method
End Type


'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()

