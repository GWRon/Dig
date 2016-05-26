SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"
Import "../../base.util.registry.spriteentityloader.bmx"
Import "../../base.util.graphicsmanager.bmx"

'init graphics
GetGraphicsManager().SetResolution(1280,720)
GetGraphicsManager().InitGraphics()
'assign update/render functions to delta timer
GetDeltaTimer().Init(30,30)
GetDeltaTimer()._funcUpdate = WorldUpdate
GetDeltaTimer()._funcRender = WorldRender


'=== LOAD RESOURCES ===
Local registryLoader:TRegistryLoader = New TRegistryLoader
'if loading from a "parent directory" - state this here
'-> all resources can get loaded with "relative paths"
'registryLoader.baseURI = "../"

'load that directly too, so we do not need to update and check for unloaded
registryLoader.LoadFromXML("res/config/myresources.xml", True)

Global mySpriteEntity:TSpriteEntity = GetSpriteEntityFromRegistry("figureSpriteEntity")
Global mySprite:TSprite = GetSpriteFromRegistry("figureSprite")

Function WorldUpdate:Int()
	If mySpriteEntity
		mySpriteEntity.Update()
	EndIf
End Function

Function WorldRender:Int()
	SetClsColor 150,150,150
	Cls
	If mySpriteEntity Then mySpriteEntity.Render()
	If mySprite Then mySprite.Draw(100,100,4)

	DrawText("mySprite: "+(mySprite <> Null), 10,10)
	DrawText("mySpriteEntity: "+(mySpriteEntity <> Null), 10,24)

	Local y:Int = 0
	For Local s:String = EachIn AppLog.Strings
		DrawText(s, 0, 40 + y)
		y:+ 11
	Next

	GetGraphicsManager().Flip()
End Function


?Not android
Const KEY_BROWSER_BACK:Int = 0
?

'simple loop
Repeat
	GetDeltaTimer().Loop()
Until KeyHit(KEY_ESCAPE) Or KeyHit(KEY_BROWSER_BACK)