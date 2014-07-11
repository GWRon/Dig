SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"

'game specific
Import "app.screen.mainmenu.bmx"
Import "app.screen.room.bmx"

Global MyApp:TMyApp = New TMyApp
MyApp.debugLevel = 1

Type TMyApp Extends TGraphicalApp
	Field mouseCursorState:Int = 0


	Method Prepare:Int()
		Super.Prepare()

		Local gm:TGraphicsManager = TGraphicsManager.GetInstance()
		'scale everything from 800x600 to 1024x768
	'	gm.SetResolution(1024, 768)
	'	gm.SetDesignedResolution(800, 600)
	'	gm.InitGraphics()

		'we use a full screen background - so no cls needed
		autoCls = True

		'=== LOAD RESOURCES ===
		Local registryLoader:TRegistryLoader = New TRegistryLoader
		'if loading from a "parent directory" - state this here
		'-> all resources can get loaded with "relative paths"
		'registryLoader.baseURI = "../"

		'afterwards we can display background images and cursors
		'"TRUE" indicates that the content has to get loaded immediately
		registryLoader.LoadFromXML("res/config/startup.xml", True)
		registryLoader.LoadFromXML("res/config/resources.xml")

		'set a basic font ?
		'SetImageFont(LoadImageFont("../res/fonts/Vera.ttf", 12))

		'=== CREATE DEMO SCREENS ===
		GetScreenManager().Set(New TScreenMainMenu.Init("mainmenu"))
		GetScreenManager().Set(New TScreenRoomBase.Init("room1"))
		GetScreenManager().Set(New TScreenRoomBase.Init("room2"))
		GetScreenManager().SetCurrent( GetScreenManager().Get("mainmenu") )
	End Method


	Method Update:Int()
		'fetch and cache mouse and keyboard states for this cycle
		GUIManager.StartUpdates()

		'=== UPDATE GUI ===
		'system wide gui elements
		GuiManager.Update("SYSTEM")

		'run parental update (screen handling)
		Super.Update()

		If Keymanager.Ishit(KEY_Y)
			EventManager.triggerEvent( TEventSimple.Create( "chat.onAddEntry", New TData.AddNumber("senderID", 1).AddNumber("channels", 1).AddString("text", "Test"+Time.GetTimeGone()) ) )
		EndIf

		'check if new resources have to get loaded
		TRegistryUnloadedResourceCollection.GetInstance().Update()

		'reset modal window states
		GUIManager.EndUpdates()
	End Method


	Method Render:Int()
		Super.Render()
	End Method


	Method RenderContent:Int()
		'=== RENDER GUI ===
		'system wide gui elements
		GuiManager.Draw("SYSTEM")
	End Method


	Method RenderLoadingResourcesInformation:Int()
		'do nothing if there is nothing to load
		If TRegistryUnloadedResourceCollection.GetInstance().FinishedLoading() Then Return True

		'reduce instance requests
		Local RURC:TRegistryUnloadedResourceCollection = TRegistryUnloadedResourceCollection.GetInstance()


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
		GetSpriteFromRegistry("gfx_mousecursor"+mouseCursorState).Draw(MouseManager.x, MouseManager.y, 0)
	End Method
End Type


'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()

