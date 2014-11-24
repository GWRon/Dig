SuperStrict
Import "../../base.util.graphicsmanager.bmx"
Import "../../base.framework.entity.spriteentity.bmx"
Import BRL.StandardIO

Global mySprites:TSprite[4]
Global myEntity:TSpriteEntity[4]
Global myImages:TImage[4]
Global myGradients:TImage[4]

for local i:int = 0 to 3
	Select i
		case 0
			MyImages[i] = LoadImage("figure.png", DYNAMICIMAGE)
			MyGradients[i] = LoadImage("gradient.png", DYNAMICIMAGE)
		case 1
			MyImages[i] = LoadImage("figure.png", DYNAMICIMAGE)
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
		case 2
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)
		case 3
			MyImages[i] = ColorizeImageCopy(MyImages[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_NEGATIVEMULTIPLY)
			MyGradients[i] = ColorizeImageCopy(MyGradients[0], TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_NEGATIVEMULTIPLY)
	End Select

	mySprites[i] = new TSprite.InitFromImage(MyImages[i], "figure"+i, 11)
	'create the entity
	myEntity[i] = new TSpriteEntity
	myEntity[i].GetFrameAnimations().Set("walkRight", TSpriteFrameAnimation.Create([ [0,130], [1,130], [2,130], [3,130] ], -1, 0) )
	myEntity[i].GetFrameAnimations().Set("walkLeft", TSpriteFrameAnimation.Create([ [4,130], [5,130], [6,130], [7,130] ], -1, 0) )
	myEntity[i].Init(mySprites[i])
	myEntity[i].area.position.SetXY(125, 50 + 50*i)
Next


global tafel:TImage = LoadImage("roomboard_sign_base.png", DYNAMICIMAGE)
global tafelCol:TImage = ColorizeImageCopy(tafel, TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_MULTIPLY)
global tafelCol2:TImage = ColorizeImageCopy(tafel, TColor.clRed, 0, 0, 0, 1, 0, COLORIZEMODE_OVERLAY)


'init graphics
GetGraphicsManager().SetResolution(640,480)
GetGraphicsManager().InitGraphics()

'assign update/render functions to delta timer
GetDeltaTimer().Init(30,30)
GetDeltaTimer()._funcUpdate = WorldUpdate
GetDeltaTimer()._funcRender = WorldRender

'just a timer for the next animation of the "sprite"
Global updateCount:int = 0



'the splitted loop - update and render

Function WorldUpdate:int()

	For local i:int = 0 to 3
		myEntity[i].Update()
		if myEntity[i].area.position.x > 120
			myEntity[i].SetVelocity(-30,0)
			myEntity[i].GetFrameAnimations().SetCurrent("walkLeft")
		endif
		if myEntity[i].area.position.x <= 0
			myEntity[i].SetVelocity(30,0)
			myEntity[i].GetFrameAnimations().SetCurrent("walkRight")
		endif
	Next
	
	updateCount :+ 1
End Function


Function WorldRender:int()
	SetClsColor 150,150,150
	Cls

	For local i:int = 0 to 3
		'draw the sprite alone
		mySprites[i].Draw(200,50 + 50*i, (updateCount/10) mod 11)
		myEntity[i].Render()
		DrawImage(myEntity[i].sprite.GetImage(), 250,50 + 50*i)
		DrawImage(myGradients[i], 520,50 + 50*i)
	Next

	DrawImage(tafel, 50,400)
	DrawImage(tafelCol, 240,400)
	DrawImage(tafelCol2, 430,400)

	For local i:int = 0 to 5
		new TColor.Create(255,0,0).AdjustSaturationRGB(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 270, 50, 30)

		new TColor.Create(255,0,0).AdjustSaturation(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 300, 50, 30)

		new TColor.Create(255,0,0).AdjustBrightness(-0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 330, 50, 30)
		
		new TColor.Create(255,0,0).AdjustBrightness(+0.2 * i).SetRGB()
		DrawRect(50 + 60*i, 360, 50, 30)
	Next
	SetColor 255,255,255

	GetGraphicsManager().Flip()
End Function


'simple loop
Repeat
	GetDeltaTimer().Loop()
Until KeyHit(KEY_ESCAPE)