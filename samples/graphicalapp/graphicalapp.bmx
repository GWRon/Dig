SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"

Global MyApp:TMyApp = New TMyApp
global startI:int = 0


Type TMyApp Extends TGraphicalApp
	Method RenderContent:Int()
		local height:int = 100
		local c:TColor = new TColor.Create(255,0,0)
		For local i:int = 0 until height
			local h:Float = ((startI+i) mod 100) / 100.0
			c.FromHSL(h, 0.5, 0.5).SetRGBA()
			DrawLine(0,i,100,i)
		Next

		For local i:int = 0 until height
			local h:Float = ((startI+i) mod 100) / 100.0
			c.FromHSL(h, 0.5 + float(sin(Millisecs()/10)) * 0.4, 0.5).SetRGBA()
			DrawLine(120,i,220,i)
		Next

		c = new TColor.Create(255,0,0)
		For local i:int = 0 until height
			local h:Float = (Max(0, ((startI+i)-50)) mod 100) / 100.0
			c.FromHSL(h, 0.5, float(0.5 + 0.5*sin(Millisecs()/10))).SetRGBA()
			DrawLine(240,i,340,i)
		Next

		c = new TColor.Create(255,0,0)
		local scaleY:Float = float(10 + 50*sin(Millisecs()/10))
		For local i:int = 0 until height
			local h:Float = Min(1.0, (i + 50 + scaleY) / 100.0)
			c.FromHSL(0.5, h, 0.5).SetRGBA()
			DrawLine(360,i,460,i)
		Next
		SetColor 120,120,120
		For local i:int = 0 to 100
			DrawLine(360+i, 0, 360+i, 10 + 10 * float(Max(-10, Sin(Millisecs()/2 + 10*i))))

			DrawLine(360+i, height - 10 + 10 * float(Max(-10, Sin(Millisecs()/2 + 10*i))),  360+i, height)
		Next
		SetColor 255,255,255


		startI :+ 1
		SetColor 255,255,255
	
	
		DrawText("FPS: "+ GetDeltaTimer().currentFPS, 100,100)
		DrawText("UPS: "+ GetDeltaTimer().currentUPS, 100,120)


		DrawText("RTPS: "+ GetDeltaTimer()._currentRenderTimePerSecond, 100,150)
		DrawText("UTPS: "+ GetDeltaTimer()._currentUpdateTimePerSecond, 100,170)
	End Method
End Type


'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()