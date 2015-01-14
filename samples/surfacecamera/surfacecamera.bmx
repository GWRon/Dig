SuperStrict
Import "../../base.util.surfacecamera.bmx"

Graphics 816,544,0
'we init the cameras with a specific resolution to simulate that
'the desired graphic resolution was not created 
Global cameraStretch:TStretchingSurfaceCamera = new TStretchingSurfaceCamera.Init([800, 480])
Global cameraExtend:TExtendingSurfaceCamera = new TExtendingSurfaceCamera.Init([800, 600, 854, 480])

global image:TImage = LoadImage("cameraareas.png")
global mode:int = 0
global graphicsMode:int = 0
global cameraType:int = 0
SetBlend AlphaBlend
Repeat
	local camera:TSurfaceCamera = TSurfaceCamera.GetActiveCamera()
	local cameraName:string = "Default"
	if TStretchingSurfaceCamera(camera) <> null then cameraName = "StretchingCamera"
	if TExtendingSurfaceCamera(camera) <> null then cameraName = "ExtendingCamera"
	local cameraText:string = "camera dimension="+camera.GetWidth()+"x"+camera.GetHeight() + "  offset="+int(camera.offsetX)+"x"+int(camera.offsetY) + "  virtualDimension="+ int(VirtualResolutionWidth())+"x"+ int(VirtualResolutionHeight())

	if KeyHit(Key_G)
		EndGraphics()
		graphicsMode :+1
		if graphicsMode > 3 then graphicsMode = 0
		Select GraphicsMode
			case 0	Graphics 1024, 768, 0
			case 1	Graphics 800, 600, 0
			case 2	Graphics 840, 480, 0
			case 3	Graphics 480, 840, 0
		EndSelect
		'reactivate camera
		camera.Activate()
	endif

	if KeyHit(Key_C)
		camera.Deactivate()
		cameraType :+1
		if cameraType > 2 then cameraType = 0
		if cameraType = 1 then cameraStretch.Activate()
		if cameraType = 2 then cameraExtend.Activate()
	endif

	if KeyHit(Key_1) then mode=0;camera.SetDimension(1024, 768)
	if KeyHit(Key_2) then mode=1;camera.SetDimension(800, 600)
	if KeyHit(Key_3) then mode=2;camera.SetDimension(840, 600)
	if KeyHit(Key_4) then mode=3;camera.SetDimension(840, 480)
	if KeyHit(Key_5) then mode=4;camera.SetDimension(800, 480)
	if KeyHit(Key_6) then mode=5;camera.SetDimension(480, 800)



	SetClsColor 100,100,100
	Cls
	'center the image
	DrawImage(image, -0.5 * (image.width - TSurfaceCamera.activeCamera.GetWidth()),-0.5 * (image.height - TSurfaceCamera.activeCamera.GetHeight()))

	SetAlpha 0.5*GetAlpha()
	DrawRect(5,45, 200, 140)
	DrawRect(camera.GetWidth() - TextWidth(cameraText) -10,0, TextWidth(cameraText)+5, 20)
	SetAlpha 2*Getalpha()

	SetColor 0,0,0
	DrawText("[1] 1024x768", 10, 50 + 0*16)
	DrawText("[2]  800x600", 10, 50 + 1*16)
	DrawText("[3]  840x600", 10, 50 + 2*16)
	DrawText("[4]  840x480", 10, 50 + 3*16)
	DrawText("[5]  800x480", 10, 50 + 4*16)
	DrawText("[6]  480x800", 10, 50 + 5*16)
	DrawText("[C] switch camera type ", 10, 50 + 7*16)
	DrawText("    ("+cameraName+")", 10, 50 + 8*16)
	DrawText("[G] switch graphics", 10, 50 + 9*16)

	DrawText(cameraText, camera.GetWidth() - TextWidth(cameraText) -5, 5)
	DrawText(int(camera.GetMouseX())+","+int(camera.GetMouseY()), camera.GetMouseX() + 10, camera.GetMouseY())

	SetColor 255,255,255
	Flip
Until KeyHit(KEY_ESCAPE) or AppTerminate()


