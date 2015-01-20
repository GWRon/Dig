SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"
Import "../../base.util.registry.spriteentityloader.bmx"
Import "../../base.util.graphicsmanager.bmx"

'init graphics
GetGraphicsManager().SetResolution(640,480)
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

'afterwards we can display background images and cursors
'"TRUE" indicates that the content has to get loaded immediately
registryLoader.LoadFromXML("res/config/startup.xml", True)

'load that directly too, so we do not need to update and check for unloaded
registryLoader.LoadFromXML("res/config/myresources.xml", True)

Global mySpriteEntity:TSpriteEntity = GetSpriteEntityFromRegistry("figureSpriteEntity")
Global mySprite:TSprite = GetSpriteFromRegistry("figureSprite")

Function WorldUpdate:Int()
	mySpriteEntity.Update()
End Function

Function WorldRender:Int()
	SetClsColor 150,150,150
	Cls
	mySpriteEntity.Render()
	mySprite.Draw(100,100,4)
	GetGraphicsManager().Flip()
End Function




'simple loop
Repeat
	GetDeltaTimer().Loop()
Until KeyHit(KEY_ESCAPE)