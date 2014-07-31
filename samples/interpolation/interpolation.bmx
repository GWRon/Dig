Rem
	Example showing how to use base.util.interpolation

	You can also use that interpolation formulas to show/hide
	buttons ("popping on/off")
End Rem
SuperStrict
'keep it small
Framework Brl.StandardIO
Import Brl.GLMax2D
Import "../../base.util.interpolation.bmx"

Graphics 640,480,0, 60
SetBlend(ALPHABLEND)

local cycleTime:Double = 0
local lastCycleTime:Double = -1
local intervalGone:Double = 0.0
local intervalTotal:Double = 2.0	'anim takes 3 seconds
local intervalDirection:int = 1		'1 -> increase, -1 -> decrease
local effectMode:int = 0

While not KeyHit(KEY_ESCAPE)
	'compute cycle time
	if lastCycleTime = -1 then lastCycleTime = Millisecs()
	cycleTime = Millisecs() - lastCycleTime
	lastCycleTime = Millisecs()

	Cls

	'calc current position
	intervalGone :+ intervalDirection * (cycleTime / 1000.0) 'in ms
	if intervalGone >= intervalTotal then intervalDirection = -1
	if intervalGone <= 0 then intervalDirection = 1

	local x:Double = 0
	local t:String = ""
	Select effectMode
		case 2	x = TInterpolation.BounceInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Bounce"
		case 3	x = TInterpolation.RegularInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Regular"
		case 4	x = TInterpolation.StrongInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Strong"
		case 5	x = TInterpolation.BackInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Back"
		case 6	x = TInterpolation.ElasticInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Elastic"
		case 7	x = TInterpolation.CircInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Circ"
		case 8	x = TInterpolation.CubicInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Cubic"
		case 9	x = TInterpolation.ExpoInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Expo"
		case 0	x = TInterpolation.QuartInOut(0.0, 1.0, intervalGone, intervalTotal)
				t = "Quart"
		default	x = TInterpolation.Linear(0.0, 1.0, intervalGone, intervalTotal)
				t = "Linear"
	EndSelect
	'x is now a value between 0 (start) and 1 (end)
	'oval is started "top left" so it ends x,y + 40,40 -> 0-400 ends at 440
	DrawOval(100 + x * 400, 150, 40, 40)
	'draw borders
	DrawRect(100, 140, 1, 60)
	DrawRect(540, 140, 1, 60)

	DrawText("ESC to quit | current mode: "+t, 20, 20)
	DrawText("[1] linear  [2] bounce [3] regular [4] strong  [5] back  [6] elastic", 20, 35)
	DrawText("[7] circ    [8] cubic  [9] expo    [0] quart", 20, 47)

	if KeyHit(Key_1) then effectMode = 1
	if KeyHit(Key_2) then effectMode = 2
	if KeyHit(Key_3) then effectMode = 3
	if KeyHit(Key_4) then effectMode = 4
	if KeyHit(Key_5) then effectMode = 5
	if KeyHit(Key_6) then effectMode = 6
	if KeyHit(Key_7) then effectMode = 7
	if KeyHit(Key_8) then effectMode = 8
	if KeyHit(Key_9) then effectMode = 9
	if KeyHit(Key_0) then effectMode = 0

	Flip -1

Wend