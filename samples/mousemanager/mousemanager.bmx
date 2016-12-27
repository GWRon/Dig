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

	If MouseManager.IsClicked(1) Then Print Time.GetTimeGone() + " | " + Time.MilliSecsLong() + ": Button 1 clicked"
	If MouseManager.IsSingleClicked(1) Then Print Time.GetTimeGone() + ": Button 1 single clicked"
	If MouseManager.IsDoubleClicked(1) Then Print Time.GetTimeGone() + ": Button 1 double clicked"
	
	If KeyDown(KEY_UP) Then MouseManager._doubleClickTime :+ 1
	If KeyDown(KEY_DOWN) Then MouseManager._doubleClickTime = Max(0, MouseManager._doubleClickTime -1)
	
	DrawText("Doubleclick time: " + MouseManager._doubleClickTime, 10, 10)
	DrawText("Press UP or DOWN to adjust time", 10, 25)

	Flip 0
Until KeyHit(KEY_ESCAPE)