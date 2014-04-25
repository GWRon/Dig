SuperStrict
Import "../../base.util.graphicsmanager.bmx"
Import "../../base.framework.entity.spriteentity.bmx"
Import BRL.StandardIO


'create sprite for entity, do not use "LoadAnimImage" as this is handled
'by the sprite class already
local image:TImage = LoadImage("spielfigur_hausmeister.png", DYNAMICIMAGE)
'that image contains 15 frames
Global mySprite:TSprite = new TSprite.InitFromImage(image, "figure", 15)
'create the entity
Global myEntity:TSpriteEntity = new TSpriteEntity
myEntity.GetFrameAnimations().Set("walkRight", TSpriteFrameAnimation.Create([ [0,130], [1,130], [2,130], [3,130] ], -1, 0) )
myEntity.GetFrameAnimations().Set("walkLeft", TSpriteFrameAnimation.Create([ [4,130], [5,130], [6,130], [7,130] ], -1, 0) )
myEntity.Init(mySprite)


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
	myEntity.Update()
	if myEntity.area.position.x > 200
		myEntity.SetVelocity(-30,0)
		myEntity.GetFrameAnimations().SetCurrent("walkLeft")
	endif
	if myEntity.area.position.x <= 0
		myEntity.SetVelocity(30,0)
		myEntity.GetFrameAnimations().SetCurrent("walkRight")
	endif

	updateCount :+ 1
End Function


Function WorldRender:int()
	SetClsColor 150,150,150
	Cls
	'draw the sprite alone
	mySprite.Draw(100,100, (updateCount/10) mod 15)
	myEntity.Render()
	DrawImage(myEntity.sprite.GetImage(), 20,200)
	GetGraphicsManager().Flip()
End Function


'simple loop
Repeat
	GetDeltaTimer().Loop()
Until KeyHit(KEY_ESCAPE)