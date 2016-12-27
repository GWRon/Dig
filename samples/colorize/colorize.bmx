SuperStrict
Framework BRL.StandardIO
Import Brl.PNGLoader
Import "../../base.util.graphicsmanager.bmx"
Import "../../base.framework.entity.spriteentity.bmx"

Global myEntity:TSpriteEntity[4]
Global myImages:TImage[4]
Global myGradients:TImage[4]

For Local i:Int = 0 To 3
	'ATTENTION: the eyes of the figure are colorized here too... to avoid
	'this, you should colorize the eyes accordingly
	Select i
		Case 0
			MyImages[i] = LoadImage("figure.png", DYNAMICIMAGE)
			MyGradients[i] = LoadImage("gradient.png", DYNAMICIMAGE)
		Case 1
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
		Case 2
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)
		Case 3
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_NEGATIVEMULTIPLY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_NEGATIVEMULTIPLY)
	End Select

	Local sprite:TSprite = New TSprite.InitFromImage(MyImages[i], "figure"+i, 11)
	'create the entity
	myEntity[i] = New TSpriteEntity
	myEntity[i].SetPosition(125, 50 + 50*i)
	myEntity[i].GetFrameAnimations().Set(TSpriteFrameAnimation.Create("walkRight", [ [0,130], [1,130], [2,130], [3,130] ], -1, 0) )
	myEntity[i].GetFrameAnimations().Set(TSpriteFrameAnimation.Create("walkLeft", [ [4,130], [5,130], [6,130], [7,130] ], -1, 0) )
	myEntity[i].Init(sprite)
Next


Global tafel:TImage = LoadImage("roomboard_sign_base.png", DYNAMICIMAGE)
Global tafelCol:TImage = ColorizeImageCopy(tafel, TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
Global tafelCol2:TImage = ColorizeImageCopy(tafel, TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)


'init graphics
GetGraphicsManager().SetResolution(640,480)
GetGraphicsManager().InitGraphics()

'assign update/render functions to delta timer
GetDeltaTimer().Init(30,30)
GetDeltaTimer()._funcUpdate = WorldUpdate
GetDeltaTimer()._funcRender = WorldRender

'just a timer for the next animation of the "sprite"
Global updateCount:Int = 0



'the splitted loop - update and render

Function WorldUpdate:Int()

	For Local i:Int = 0 To 3
		myEntity[i].Update()
		If myEntity[i].area.position.x > 120
			myEntity[i].SetVelocity(-30,0)
			myEntity[i].GetFrameAnimations().SetCurrent("walkLeft")
		EndIf
		If myEntity[i].area.position.x <= 0
			myEntity[i].SetVelocity(30,0)
			myEntity[i].GetFrameAnimations().SetCurrent("walkRight")
		EndIf
	Next
	
	updateCount :+ 1
End Function


Function WorldRender:Int()
	SetClsColor 150,150,150
	Cls

	For Local i:Int = 0 To 3
		'draw the sprite alone
		myEntity[i].sprite.Draw(200,50 + 50*i, (updateCount/10) Mod 11)
		myEntity[i].Render()
		DrawImage(myEntity[i].sprite.GetImage(), 250,50 + 50*i)
		DrawImage(myGradients[i], 520,50 + 50*i)
	Next

	DrawImage(tafel, 50,400)
	DrawImage(tafelCol, 240,400)
	DrawImage(tafelCol2, 430,400)

	DrawText("Saturation RGB -20%", 410, 280)
	DrawText("Saturation -20%", 410, 310)
	DrawText("Brightness -20%", 410, 340)
	DrawText("Brightness +20%", 410, 370)
	For Local i:Int = 0 To 5
		New TColor.Create(255,0,0).AdjustSaturationRGB(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 270, 50, 30)

		New TColor.Create(255,0,0).AdjustSaturation(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 300, 50, 30)

		New TColor.Create(255,0,0).AdjustBrightness(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 330, 50, 30)
		
		New TColor.Create(100,0,50).AdjustBrightness(+0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 360, 50, 30)
	Next
	SetColor 255,255,255


	myEntity[0].sprite.Draw(0, GetGraphicsManager().GetHeight(), 0, ALIGN_LEFT_BOTTOM)
	myEntity[0].sprite.Draw(GetGraphicsManager().GetWidth(), GetGraphicsManager().GetHeight(), 5, ALIGN_RIGHT_BOTTOM)


	GetGraphicsManager().Flip()
End Function


'simple loop
Repeat
	GetDeltaTimer().Loop()
Until KeyHit(KEY_ESCAPE)