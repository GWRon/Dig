SuperStrict
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.framework.toastmessage.bmx"

Global MyApp:TMyApp = new TMyApp

Type TMyApp extends TGraphicalApp
	Method Update:int()
		Super.Update()
		GetToastMessageCollection().Update()

		if KeyManager.IsHit(KEY_SPACE)
			local toast:TToastMessage = new TToastMessage
			toast.SetLifeTime( Rand(10000,15000)/1000.0 )
			Select rand(0,3)
				case 0
					GetToastMessageCollection().AddMessage(toast, "TOPLEFT")
				case 1
					GetToastMessageCollection().AddMessage(toast, "TOPRIGHT")
				case 2
					GetToastMessageCollection().AddMessage(toast, "BOTTOMLEFT")
				case 3
					GetToastMessageCollection().AddMessage(toast, "BOTTOMRIGHT")
			EndSelect
		endif
	End Method


	Method RenderContent:int()
		GetToastMessageCollection().Render(0,0)
	End Method


	Method RenderDebug:int()
		DrawText("FPS: "+ GetDeltaTimer().currentFPS, 100,10)
		DrawText("UPS: "+ GetDeltaTimer().currentUPS, 190,10)
		DrawText("RTPS: "+ GetDeltaTimer()._currentRenderTimePerSecond, 100,20)
		DrawText("UTPS: "+ GetDeltaTimer()._currentUpdateTimePerSecond, 190,20)

		SetColor 0,0,0
		DrawRect(MouseManager.x-3, MouseManager.y-3, 7,7)
		SetColor 255,255,255
		DrawRect(MouseManager.x-2, MouseManager.y-2, 5,5)
	End Method
End Type

'1-3 Bloecke-Anzeige ermoeglichen (bei Serien mit abweichenden Blocklaengen)


'register toaster position: position, alignment, name
GetToastMessageCollection().AddNewSpawnPoint( new TRectangle.Init(20,20, 300,200), new TVec2D.Init(0,0), "TOPLEFT" )
GetToastMessageCollection().AddNewSpawnPoint( new TRectangle.Init(480,20, 300, 200), new TVec2D.Init(1,0), "TOPRIGHT" )
GetToastMessageCollection().AddNewSpawnPoint( new TRectangle.Init(20,380, 300,200), new TVec2D.Init(0,1), "BOTTOMLEFT" )
GetToastMessageCollection().AddNewSpawnPoint( new TRectangle.Init(480,380, 300, 200), new TVec2D.Init(1,1), "BOTTOMRIGHT" )

local toast:TToastMessage
toast = new TToastMessage
GetToastMessageCollection().AddMessage(toast, "TOPLEFT")

toast = new TToastMessage
GetToastMessageCollection().AddMessage(toast, "TOPRIGHT")

toast = new TToastMessage
GetToastMessageCollection().AddMessage(toast, "BOTTOMLEFT")

toast = new TToastMessage
GetToastMessageCollection().AddMessage(toast, "BOTTOMRIGHT")



'kickoff
MyApp.SetTitle("Demo Toastmessages")
MyApp.debugLevel = 1 'to show fps/ups..
MyApp.Run()