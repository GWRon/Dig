SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"

Import "app.screen.gui.bmx"


Global MyApp:TMyApp = New TMyApp
MyApp.debugLevel = 1


'kickoff
MyApp.SetTitle("GUI widgets")
MyApp.Run()
end




'-------------------

Type TMyApp Extends TGraphicalApp
	Field mouseCursorState:Int = 0


	Method Prepare:Int()
		Super.Prepare()

		Local gm:TGraphicsManager = TGraphicsManager.GetInstance()
		'scale everything from 800x600 to 1024x768
		'gm.SetResolution(1024, 768)
		'gm.SetDesignedResolution(800, 600)
		'gm.InitGraphics()

		GetDeltatimer().Init(30, -1)
		GetGraphicsManager().SetVsync(FALSE)
		GetGraphicsManager().SetResolution(800,600)
		GetGraphicsManager().InitGraphics()	

		'we use a full screen background - so no cls needed
		autoCls = True

		'=== LOAD RESOURCES ===
		Local registryLoader:TRegistryLoader = New TRegistryLoader
		'afterwards we can display background images and cursors
		'"TRUE" indicates that the content has to get loaded immediately
		registryLoader.LoadFromXML("res/config/startup.xml", True)
		'load this "deferred"
		registryLoader.LoadFromXML("res/config/resources.xml")

		'=== CREATE DEMO SCREENS ===
		GetScreenManager().Set(New TScreenGui.Init("page1"))
		GetScreenManager().SetCurrent( GetScreenManager().Get("page1") )
	End Method


	Method Update:Int()
		'fetch and cache mouse and keyboard states for this cycle
		GUIManager.StartUpdates()

		'=== UPDATE GUI ===
		'system wide gui elements
		GuiManager.Update("SYSTEM")

		'run parental update (screen handling)
		Super.Update()

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

