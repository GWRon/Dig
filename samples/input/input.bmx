SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"

Global MyApp:TMyApp = New TMyApp
MouseManager._ignoreFirstClick = True
'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()




Type TMyApp Extends TGraphicalApp
	Method Update:Int()
'		MouseManager.Update()
'		KeyManager.Update()
		Super.Update()

		TMouseAction.UpdateAll()

		If MouseManager.IsDown(1)
			TMouseAction.Add(-1,-1, 1) 'trail
		EndIf
		If MouseManager.IsShortClicked(1) Then TMouseAction.Add(-1,-1, 2)
		If MouseManager.IsLongClicked(1) Then TMouseAction.Add(-1,-1, 3)
		If MouseManager.IsDoubleClicked(1) Then TMouseAction.Add(-1,-1, 4)
		If MouseManager.IsHit(1) Then TMouseAction.Add(-1,-1, 5)

'		if KeyManager.IsHit(KEY_ESCAPE) then exit
	End Method

	Method RenderContent:Int()
		DrawText("FPS: "+ GetDeltaTimer().currentFPS, 20,100)
		DrawText("UPS: "+ GetDeltaTimer().currentUPS, 20,120)

		DrawText("RTPS: "+ GetDeltaTimer()._currentRenderTimePerSecond, 20,150)
		DrawText("UTPS: "+ GetDeltaTimer()._currentUpdateTimePerSecond, 20,170)

		DrawText("MOUSE:"+ TMouseAction.list.Count(), 20,200)
		DrawText(" Actions:"+ TMouseAction.list.Count(), 20,220)
		DrawText(" hasIgnoredFirstClick[1]: "+ MouseManager._hasIgnoredFirstClick[1], 20,240)

		Select MouseManager._keyStatus[1]
			Case KEY_STATE_UP
				DrawText(" keyStatus[1]: UP", 20,260)
			Case KEY_STATE_DOWN
				DrawText(" keyStatus[1]: DOWN", 20,260)
			Case KEY_STATE_HIT
				DrawText(" keyStatus[1]: HIT", 20,260)
			Case KEY_STATE_NORMAL
				DrawText(" keyStatus[1]: NORMAL", 20,260)
			Default
				DrawText(" keyStatus[1]: ???", 20,260)
		End Select

		TMouseAction.DrawAll()


		SetColor 150,100,100
		DrawOval(MouseX()-3, MouseY()-3, 6,6)
		SetColor 255,255,255
		DrawOval(MouseManager.x-3, MouseManager.y-3, 6,6)
	End Method
End Type


Type TMouseAction
	Field x:Int, y:Int
	Field kind:Int
	Global lastTrail:TMouseAction
	Global list:TList = CreateList()

	Function Add:TMouseAction(x:Int, y:Int, kind:Int)
		If x < 0 Then x = MouseManager.x
		If y < 0 Then y = MouseManager.y

		'last = current -> skip
		If kind = 1 And lastTrail And lastTrail.x = x And lastTrail.y = y Then Return Null

		Local obj:TMouseAction = New TMouseAction
		obj.x = x
		obj.y = y
		obj.kind = kind

		If kind = 1 Then lastTrail = obj

		list.AddLast(obj)
		Return obj
	End Function

	Method Draw(previous:TMouseAction)
		If kind = 1 'mouse trail
			If previous
				DrawLine(previous.x, previous.y, x, y)
			Else
				Plot(x, y)
			EndIf
		ElseIf kind = 2 'clicks
			SetColor 100,100,150
			DrawOval(x-10, y-10, 20,20)
			DrawText ("Click", x-10,y-24)
		ElseIf kind = 3 'long clicks
			SetColor 100,150,150
			DrawOval(x-8, y-8, 16,16)
			DrawText ("Long", x-45,y-4)
		ElseIf kind = 4 'double clicks
			SetColor 150,100,150
			DrawOval(x-6, y-6, 12,12)
			DrawText ("Dbl", x+20,y-4)
		ElseIf kind = 5 'hits
			SetColor 100,150,100
			DrawOval(x-4, y-4, 8,8)
			DrawText ("Hit", x-9,y+12)
		EndIf
		SetColor 255,255,255
	End Method

	Function DrawAll()
		Local previousTrail:TMouseAction
		For Local a:TMouseAction = EachIn list
			a.Draw(previousTrail)
			If a.kind = 1 Then previousTrail = a
		Next
	End Function

	Function UpdateAll()
		While list.Count() > 100
			list.RemoveFirst()
		Wend
	End Function
End Type