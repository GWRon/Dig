SuperStrict
Framework Brl.StandardIO

Import Brl.Graphics
Import Brl.GLMax2D
Import "../../base.util.input.bmx"
Import "../../base.util.time.bmx"

Graphics 640,480,0

'MouseManager.Init()
Repeat
	Cls

	MouseManager.Update()

	If MouseManager.IsClicked(1)
		Print Time.GetTimeGone() + " | " + Time.MilliSecsLong() + ": Button 1 clicked"
		MouseManager.SetClickHandled(1)
	EndIf
	If MouseManager.IsLongClicked(1)
		Print Time.GetTimeGone() + ": Button 1 long clicked"
		MouseManager.SetLongClickHandled(1)
	EndIf
	If MouseManager.IsDoubleClicked(1)
		Print Time.GetTimeGone() + ": Button 1 double clicked"
		MouseManager.SetDoubleClickHandled(1)
	EndIf

	If KeyDown(KEY_UP) Then MouseManager.doubleClickMaxTime :+ 1
	If KeyDown(KEY_DOWN) Then MouseManager.doubleClickMaxTime = Max(0, MouseManager.doubleClickMaxTime -1)

	DrawText("Doubleclick time: " + MouseManager.doubleClickMaxTime, 10, 10)
	DrawText("Press UP or DOWN to adjust time", 10, 25)

	Flip 0
Until KeyHit(KEY_ESCAPE)