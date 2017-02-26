SuperStrict
'keep it small
Framework Brl.StandardIO
Import Brl.GLMax2D
Import "../../base.gfx.bitmapfont.bmx"



Graphics 640,480,0, 60
SetBlend(ALPHABLEND)

Local cycleTime:Double = 0
Local lastCycleTime:Double = -1
Local direction:Int = 1
Local x:Float = 0.0

Local font:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-Regular.ttf", 12, SMOOTHFONT)
Local fontB:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-Bold.ttf", 12, SMOOTHFONT | BOLDFONT)
Local fontBI:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-BoldIt.ttf", 12, SMOOTHFONT | BOLDFONT | ITALICFONT)
Local fontI:TBitmapFont = GetBitmapFontManager().Add("Default", "../__res/font/sourcesans/SourceSansPro-It.ttf", 12, SMOOTHFONT | ITALICFONT)
'also set as imagefont
'SetImageFont(font.FImageFont)

Local f:TBitmapFont = GetBitmapFontManager().Get("Default", 12)
Local appExit:Int = False


'render some text into a new image
local pix:TPixmap = CreatePixmap(130,50, PF_RGBA8888)
pix.ClearPixels(0)
local img:TImage = LoadImage(pix)
Local hintColor:TColor = New TColor.Create(130,130,130)
Local hintColorGood:TColor = New TColor.Create(230,90,90)
TBitmapFont.setRenderTarget(pix)
SetAlpha 0.75
fontB.DrawBlock("normal", 0, 0, 100, 15, ALIGN_LEFT_CENTER, hintColor)
SetAlpha 1.0
font.DrawBlock("farbig", 0, 15, 100, 15, ALIGN_LEFT_CENTER, hintColorGood)

'GetBitmapFont("Default",13).DrawBlock("Rendered to |b|an |color=255,0,100|image |/color||/b| instead of the |i|screen|/i||/b|.", 0,0, 130,50, Null,TColor.Create(175,175,140))
SetAlpha 1.0
TBitmapFont.setRenderTarget(null)



While Not KeyHit(KEY_ESCAPE) And Not appExit
	'compute cycle time
	If lastCycleTime = -1 Then lastCycleTime = MilliSecs()
	cycleTime = MilliSecs() - lastCycleTime
	lastCycleTime = MilliSecs()

	Cls

	SetColor 255,100,100
	SetAlpha 0.3
	DrawRect(150,100,200,200)
	SetAlpha 1.0
	SetColor 255,255,255

	f.DrawBlock("Left Top", 150, 100, 200, 200, ALIGN_LEFT_TOP)
	f.DrawBlock("Right Top", 150, 100, 200, 200, ALIGN_RIGHT_TOP)
	f.DrawBlock("Left Bottom", 150, 100, 200, 200, ALIGN_LEFT_BOTTOM)
	f.DrawBlock("Right Bottom", 150, 100, 200, 200, ALIGN_RIGHT_BOTTOM)
	f.DrawBlock("Center", 150, 100, 200, 200, ALIGN_CENTER_CENTER)

	'calc current position of dynamic text thingie
	x :+ direction * (cycleTime / 1000.0) 'in ms
	If x >= 1.0 Then direction = -1
	If x <= 0 Then direction = 1

	f.DrawBlock("Bounce", 150, 100, 200, 200, New TVec2D.Init(x, 0.3))

	GetBitmapFont("Default",13).DrawBlock("Long text missing some stuff? Does it eat characters, or not?", 500,200, 98,250, Null, TColor.clWhite)

	GetBitmapFont("Default",13).DrawBlock("Showing some line-breaking stuff. Does it eat characters, or not?", 500,400, 130,250, Null, TColor.clWhite)

	GetBitmapFont("Default",13).DrawBlock("Let's test a bit |b|bold |color=255,0,0|Text |color=255,255,0|or|/color| |i|italic bold|/color| one|/i||/b|. Yeah!", 10,400, 120,250, Null,TColor.Create(175,175,140))


	Local t:String = "Let's test if |b|bold |color=255,0,0|colored |color=255,255,0|or|/color| |i|italic bold|/color| Text|/i||/b| leads to incorrect dimensions!"
	SetColor 150,150,150
	DrawRect(10, 10, GetBitmapFont("Default",13).GetWidth(t), GetBitmapFont("Default",13).GetMaxCharHeight())
	SetColor 255,255,255
	GetBitmapFont("Default",13).DrawBlock(t, 10,10, 450,150, Null,TColor.clWhite)

	t = "Let's test if bold colored or italic bold Text leads to incorrect dimensions!"
	SetColor 150,150,150
	DrawRect(10, 40, GetBitmapFont("Default",13).GetWidth(t), GetBitmapFont("Default",13).GetMaxCharHeight())
	SetColor 255,255,255
	GetBitmapFont("Default",13).DrawBlock(t, 10,40, 450,150, Null,TColor.clWhite)

	if img
		f.Draw("Rendered To Texture:", 10,315)
		DrawImage(img, 10, 330)
	endif

	Flip -1
Rem
	Repeat
		if KeyHit(KEY_ESCAPE) then appExit=True;exit
		delay(25)
	until appExit
endrem
Wend