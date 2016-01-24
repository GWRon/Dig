SuperStrict

'keep it small
Framework BRL.standardIO
'Import pub.opengles
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"

'app/game specific
Import "app.screen.mainmenu.bmx"
Import "app.screen.room.bmx"
Import "app.toastmessage.bmx"

Global MyApp:TMyApp = New TMyApp
MyApp.debugLevel = 1

Type TMyApp Extends TGraphicalApp
	Field mouseCursorState:Int = 0

	Method Prepare:Int()
		Super.Prepare()

		Local gm:TGraphicsManager = TGraphicsManager.GetInstance()
		'scale everything from 800x600 to 1024x768
		'gm.SetResolution(1024, 768)
		gm.SetResolution(800, 600)
		gm.SetDesignedResolution(800,600)
		'gm.SetFullscreen(True)
		gm.InitGraphics()	

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


		'register toaster position: position, alignment, name
		GetToastMessageCollection().AddNewSpawnPoint( New TRectangle.Init(20,20, 380,280), New TVec2D.Init(0,0), "TOPLEFT" )
		GetToastMessageCollection().AddNewSpawnPoint( New TRectangle.Init(400,20, 380,280), New TVec2D.Init(1,0), "TOPRIGHT" )
		GetToastMessageCollection().AddNewSpawnPoint( New TRectangle.Init(20,300, 380,280), New TVec2D.Init(0,1), "BOTTOMLEFT" )
		GetToastMessageCollection().AddNewSpawnPoint( New TRectangle.Init(400,300, 380,280), New TVec2D.Init(1,1), "BOTTOMRIGHT" )


		GenerateRandomToast()
		GenerateRandomToast()


		'set worldTime to 20:00, day 3 of 12 a year, in 1985
		GetWorldTime().SetTimeGone( GetWorldTime().MakeTime(1985, 3, 20, 0, 0) )
		'set speed 10x realtime
		GetWorldTime().SetTimeFactor(10)
	End Method


	Method Update:Int()
		'fetch and cache mouse and keyboard states for this cycle
		GUIManager.StartUpdates()

		'update toastmessages
		GetToastMessageCollection().Update()

		'update worldtime (eg. in games this is the ingametime)
		GetWorldTime().Update()


		'=== UPDATE GUI ===
		'system wide gui elements
		GuiManager.Update("SYSTEM")

		'run parental update (screen handling)
		Super.Update()


		If KeyManager.IsHit(KEY_T) Then GenerateRandomToast()

		'check if new resources have to get loaded
		TRegistryUnloadedResourceCollection.GetInstance().Update()

		'reset modal window states
		GUIManager.EndUpdates()
	End Method


	Method GenerateRandomToast()
			Local toast:TAppToastMessage = New TAppToastMessage
			toast.SetLifeTime( Rand(10000,15000)/1000.0 )
			toast.SetMessageType(Rand(0,3))
			toast.SetPriority(Rand(0,10))
			toast.SetCaption("Testnachricht" + MilliSecs())
			toast.SetText("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam")

			If Rand(0,1) = 1
				toast.SetCaption("Lorem ipsum dolor sit amet")
				toast.SetLifeTime(-1)
				'close in 1 worldTime minute
				toast.SetCloseAtWorldTime( GetWorldTime().GetTimeGone() + Rand(60,120))
			EndIf

			rem
			Select Rand(0,3)
				Case 0
					GetToastMessageCollection().AddMessage(toast, "TOPLEFT")
				Case 1
					GetToastMessageCollection().AddMessage(toast, "TOPRIGHT")
				Case 2
					GetToastMessageCollection().AddMessage(toast, "BOTTOMLEFT")
				Case 3
					GetToastMessageCollection().AddMessage(toast, "BOTTOMRIGHT")
			EndSelect
			endrem
			GetToastMessageCollection().AddMessage(toast, "BOTTOMRIGHT")
	End Method


	Method Render:Int()
		Super.Render()
	End Method


	Method RenderContent:Int()
		'=== RENDER TOASTMESSAGES ===
		GetToastMessageCollection().Render(0,0)

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

		DrawText("worldTime: "+GetWorldTime().GetFormattedTime(-1, "h:i:s")+ " at day "+GetWorldTime().GetDayOfYear()+" in "+GetWorldTime().GetYear(), 80, 0)

		'=== DRAW MOUSE CURSOR ===
'		GetSpriteFromRegistry("gfx_mousecursor"+mouseCursorState).Draw(MouseManager.x - 12, MouseManager.y - 3, 0)
		GetSpriteFromRegistry("gfx_mousecursor"+mouseCursorState).Draw(MouseManager.x, MouseManager.y, 0)
		'DrawOval(MouseManager.x - 12 - 1, MouseManager.y - 3 - 1, 2,2)
	End Method
End Type


'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()



