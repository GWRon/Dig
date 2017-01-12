SuperStrict
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.gfx.tooltip.base.bmx"
Import "../../base.gfx.gui.bmx"

Global MyApp:TMyApp = new TMyApp

Type TMyApp extends TGraphicalApp
	Field tooltip:TTooltipBase
	Field tooltip2:TTooltipBase
	
	Method Prepare:int()
		Super.Prepare()

		tooltip = new TTooltipBase.Initialize("Caption", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip.alignment = ALIGN_CENTER_BOTTOM
		tooltip.offset = new TVec2D.Init(0,-20)
		tooltip.parentArea = new TRectangle.Init(100,100,50,50)
		tooltip.parentAlignment = ALIGN_CENTER_TOP
		'tooltip._fixedTitleHeight = 25
		'only "tooltip-width" is used if that is smaller!
		tooltip._minContentDim = new TVec2D.Init(300,0)
		'tooltip.SetLifetime(10000)
		'tooltip.onMouseOver()

		tooltip2 = new TTooltipBase.Initialize("Caption", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip2.alignment = ALIGN_CENTER_BOTTOM
		tooltip2.offset = new TVec2D.Init(0,-20)
		tooltip2.parentArea = new TRectangle.Init(200,100,50,50)
		tooltip2.parentAlignment = ALIGN_CENTER_TOP

	End Method

	
	Method Update:int()
		Super.Update()

		if tooltip then tooltip.Update()
		if tooltip2 then tooltip2.Update()
	End Method


	Method RenderContent:int()
		SetClsColor 100,200,100

		SetColor 200,0,0
		DrawRect(100,100,50,50)
		SetColor 100,100,0
		DrawRect(200,100,50,50)
		SetColor 255, 255, 255
		
		if tooltip then tooltip.Render()
		if tooltip2 then tooltip2.Render()
	End Method


	Method RenderDebug:int()
		DrawText("FPS: "+ GetDeltaTimer().currentFPS, 100,10)
		DrawText("UPS: "+ GetDeltaTimer().currentUPS, 190,10)
		DrawText("RTPS: "+ GetDeltaTimer()._currentRenderTimePerSecond, 100,20)
		DrawText("UTPS: "+ GetDeltaTimer()._currentUpdateTimePerSecond, 190,20)

		SetColor 0,0,0
		DrawRect(MouseManager.x-3, MouseManager.y-3, 7,7)
		SetColor 255,255,255
		DrawRect(MouseManager.x-2, MouseManager.y-2, 5,5)
	End Method
End Type

'kickoff
MyApp.SetTitle("Demo Tooltips")
MyApp.debugLevel = 1 'to show fps/ups..
MyApp.Run()




Type TGuiWrapperEntity extends TRenderableEntity
	Field guiobject:TGUIObject

	Method SetGuiObject(obj:TGuiObject)
		guiobject = obj
	End Method

	Method Render:Int(xOffset:Float = 0, yOffset:Float = 0, alignment:TVec2D = Null)
		RenderChildren(xOffset, yOffset, alignment)
		if guiobject then guiobject.Draw()
	End Method

	Method Update:Int()
		UpdateChildren()
		if guiobject then guiobject.Update()
	End Method
End Type
