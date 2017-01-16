SuperStrict
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.gfx.tooltip.base.bmx"
Import "../../base.gfx.gui.bmx"

Global MyApp:TMyApp = new TMyApp

Type TMyApp extends TGraphicalApp
	Field tooltip:TTooltipBase
	Field tooltip2:TTooltipBase
	Field tooltip3:TTooltipBase
	Field tooltip4:TTooltipBase
	Field tooltipLeft1:TTooltipBase
	Field tooltipLeft2:TTooltipBase
	Field tooltipRight1:TTooltipBase
	Field tooltipRight2:TTooltipBase

	
	Method Prepare:int()
		Super.Prepare()

		tooltip = new TTooltipBase.Initialize("Caption", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip.offset = new TVec2D.Init(0,-5)
		tooltip.parentArea = new TRectangle.Init(100,100,50,50)
		'tooltip._fixedTitleHeight = 25
		'only "tooltip-width" is used if that is smaller!
		tooltip._minContentDim = new TVec2D.Init(300,0)
		'tooltip.SetLifetime(10000)
		'tooltip.onMouseOver()


		tooltip2 = new TTooltipBase.Initialize("", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip2.offset = new TVec2D.Init(0,-5)
		tooltip2.parentArea = new TRectangle.Init(200,30,50,50)


		tooltip3 = new TTooltipBase.Initialize("", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip3.offset = new TVec2D.Init(0,-5)
		tooltip3.parentArea = new TRectangle.Init(200,520,50,50)
		tooltip3.parentAlignment = ALIGN_CENTER_BOTTOM
		tooltip3.alignment = ALIGN_CENTER_TOP


		tooltip4 = new TTooltipBase.Initialize("", "content~nAnd now a long long long line which exceeds max.", new TRectangle.Init(0,0,250,-1))
		tooltip4.offset = new TVec2D.Init(0,5)
		tooltip4.parentArea = new TRectangle.Init(100,490,50,50)
		tooltip4.parentAlignment = ALIGN_CENTER_BOTTOM
		tooltip4.alignment = ALIGN_CENTER_TOP


		tooltipLeft1 = new TTooltipBase.Initialize("Left", "on the left side", new TRectangle.Init(0,0,250,-1))
		tooltipLeft1.offset = new TVec2D.Init(-5,0)
		tooltipLeft1.parentArea = new TRectangle.Init(100,200,50,50)
		tooltipLeft1.parentAlignment = ALIGN_LEFT_CENTER
		tooltipLeft1.alignment = ALIGN_RIGHT_CENTER

		tooltipLeft2 = new TTooltipBase.Initialize("Left", "on the left side", new TRectangle.Init(0,0,250,-1))
		tooltipLeft2.offset = new TVec2D.Init(-5,0)
		tooltipLeft2.parentArea = new TRectangle.Init(400,200,50,50)
		tooltipLeft2.parentAlignment = ALIGN_LEFT_CENTER
		tooltipLeft2.alignment = ALIGN_RIGHT_CENTER


		tooltipRight1 = new TTooltipBase.Initialize("Right", "on the right side", new TRectangle.Init(0,0,250,-1))
		tooltipRight1.offset = new TVec2D.Init(5,0)
		tooltipRight1.parentArea = new TRectangle.Init(700,250,50,50)
		tooltipRight1.parentAlignment = ALIGN_RIGHT_CENTER
		tooltipRight1.alignment = ALIGN_LEFT_CENTER

		tooltipRight2 = new TTooltipBase.Initialize("Right", "on the right side", new TRectangle.Init(0,0,250,-1))
		tooltipRight2.offset = new TVec2D.Init(5,0)
		tooltipRight2.parentArea = new TRectangle.Init(400,250,50,50)
		tooltipRight2.parentAlignment = ALIGN_RIGHT_CENTER
		tooltipRight2.alignment = ALIGN_LEFT_CENTER

		tooltipRight2.SetOrientationPreset("BOTTOM", 5)
	End Method

	
	Method Update:int()
		Super.Update()

		if tooltip then tooltip.Update()
		if tooltip2 then tooltip2.Update()
		if tooltip3 then tooltip3.Update()
		if tooltip4 then tooltip4.Update()
		if tooltipLeft1 then tooltipLeft1.Update()
		if tooltipLeft2 then tooltipLeft2.Update()
		if tooltipRight1 then tooltipRight1.Update()
		if tooltipRight2 then tooltipRight2.Update()
	End Method


	Method RenderContent:int()
		SetClsColor 100,200,100

		SetColor 200,0,0
		DrawRect(100,100,50,50)
		SetColor 100,100,0
		DrawRect(200,30,50,50)
		SetColor 100,0,100
		DrawRect(200,520,50,50)
		SetColor 0,0,100
		DrawRect(100,490,50,50)
		SetColor 255, 255, 255
		SetColor 150,0,100
		DrawRect(100,200,50,50)
		SetColor 50,200,100
		DrawRect(400,200,50,50)
		SetColor 150,0,200
		DrawRect(700,250,50,50)
		SetColor 50,200,200
		DrawRect(400,250,50,50)
		SetColor 255, 255, 255
		
		if tooltip then tooltip.Render()
		if tooltip2 then tooltip2.Render()
		if tooltip3 then tooltip3.Render()
		if tooltip4 then tooltip4.Render()
		if tooltipLeft1 then tooltipLeft1.Render()
		if tooltipLeft2 then tooltipLeft2.Render()
		if tooltipRight1 then tooltipRight1.Render()
		if tooltipRight2 then tooltipRight2.Render()
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
