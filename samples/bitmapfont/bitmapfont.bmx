SuperStrict
'keep it small
Framework Brl.StandardIO
Import Brl.GLMax2D
Import "../../base.gfx.bitmapfont.bmx"



Graphics 640,480,0, 60
SetBlend(ALPHABLEND)

local cycleTime:Double = 0
local lastCycleTime:Double = -1
local direction:int = 1
local x:float = 0.0

Local font:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-Regular.ttf", 12, SMOOTHFONT)
Local fontB:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-Bold.ttf", 12, SMOOTHFONT | BOLDFONT)
Local fontBI:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-BoldIt.ttf", 12, SMOOTHFONT | BOLDFONT | ITALICFONT)
Local fontI:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-It.ttf", 12, SMOOTHFONT | ITALICFONT)
'also set as imagefont
'SetImageFont(font.FImageFont)


local f:TBitmapFont = GetBitmapFontManager().Get("Default", 12)
local appExit:int = False

While not KeyHit(KEY_ESCAPE) and not appExit
	'compute cycle time
	if lastCycleTime = -1 then lastCycleTime = Millisecs()
	cycleTime = Millisecs() - lastCycleTime
	lastCycleTime = Millisecs()

	Cls

	SetColor 255,100,100
	SetAlpha 0.3
	DrawRect(150,100,200,200)
	Setalpha 1.0
	SetColor 255,255,255

	f.DrawBlock("Left Top", 150, 100, 200, 200, ALIGN_LEFT_TOP)
	f.DrawBlock("Right Top", 150, 100, 200, 200, ALIGN_RIGHT_TOP)
	f.DrawBlock("Left Bottom", 150, 100, 200, 200, ALIGN_LEFT_BOTTOM)
	f.DrawBlock("Right Bottom", 150, 100, 200, 200, ALIGN_RIGHT_BOTTOM)
	f.DrawBlock("Center", 150, 100, 200, 200, ALIGN_CENTER_CENTER)

	'calc current position of dynamic text thingie
	x :+ direction * (cycleTime / 1000.0) 'in ms
	if x >= 1.0 then direction = -1
	if x <= 0 then direction = 1

	f.DrawBlock("Bounce", 150, 100, 200, 200, new TVec2D.Init(x, 0.3))

	GetBitmapFont("Default",13).DrawBlock("Long text missing some stuff? Does it eat characters, or not?", 500,200, 98,250, null, TColor.clWhite)

	GetBitmapFont("Default",13).DrawBlock("Showing some line-breaking stuff. Does it eat characters, or not?", 500,400, 130,250, null, TColor.clWhite)

	GetBitmapFont("Default",13).DrawBlock("Let's test a bit |b|bold |color=255,0,0|Text |color=255,255,0|or|/color| |i|italic bold|/color| one|/i||/b|. Yeah!", 10,400, 120,250, Null,TColor.Create(175,175,140))

	Flip -1
rem
	Repeat
		if KeyHit(KEY_ESCAPE) then appExit=True;exit
		delay(25)
	until appExit
endrem
Wend