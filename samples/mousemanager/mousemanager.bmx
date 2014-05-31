SuperStrict
Framework Brl.StandardIO

Import Brl.Graphics
Import Brl.GLMax2D
Import "../../base.util.input.bmx"
Import "../../base.util.time.bmx"

Graphics 640,480,0

'MouseManager.Init()
Repeat
	cls

	MouseManager.Update()

	if MouseManager.IsClicked(1) then print Time.GetTimeGone() + " | " + Time.MilliSecsLong() + ": Button 1 clicked"
	if MouseManager.IsSingleClicked(1) then print Time.GetTimeGone() + ": Button 1 single clicked"
	if MouseManager.IsDoubleClicked(1) then print Time.GetTimeGone() + ": Button 1 double clicked"

	flip 0
Until KeyHit(KEY_ESCAPE)