SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"

Global MyApp:TMyApp = new TMyApp

Type TMyApp extends TGraphicalApp
	Method RenderContent:int()
		DrawText("FPS: "+ GetDeltaTimer().currentFPS, 100,100)
		DrawText("UPS: "+ GetDeltaTimer().currentUPS, 100,120)


		DrawText("RTPS: "+ GetDeltaTimer()._currentRenderTimePerSecond, 100,150)
		DrawText("UTPS: "+ GetDeltaTimer()._currentUpdateTimePerSecond, 100,170)
	End Method
End Type


'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()