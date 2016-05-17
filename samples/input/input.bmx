SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"

Global MyApp:TMyApp = new TMyApp
MouseManager._ignoreFirstClick = True
'kickoff
MyApp.SetTitle("Demoapp")
MyApp.Run()




Type TMyApp extends TGraphicalApp
	Method Update:int()
'		MouseManager.Update()
'		KeyManager.Update()
		Super.Update()

		TMouseAction.UpdateAll()

		if MouseManager.IsDown(1)
			TMouseAction.Add(-1,-1, 1) 'trail
		endif
		if MouseManager.IsShortClicked(1) then TMouseAction.Add(-1,-1, 2)
		if MouseManager.IsLongClicked(1) then TMouseAction.Add(-1,-1, 3)
		if MouseManager.IsDoubleClicked(1) then TMouseAction.Add(-1,-1, 4)
		if MouseManager.IsHit(1) then TMouseAction.Add(-1,-1, 5)

'		if KeyManager.IsHit(KEY_ESCAPE) then exit
	End Method

	Method RenderContent:int()
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
		DrawOval(MouseX()-3, Mousey()-3, 6,6)
		SetColor 255,255,255
		DrawOval(MouseManager.x-3, MouseManager.y-3, 6,6)
	End Method
End Type


Type TMouseAction
	Field x:int, y:int
	Field kind:int
	Global lastTrail:TMouseAction
	Global list:TList = CreateList()

	Function Add:TMouseAction(x:int, y:int, kind:int)
		if x < 0 then x = MouseManager.x
		if y < 0 then y = MouseManager.y

		'last = current -> skip
		if kind = 1 and lastTrail and lastTrail.x = x and lastTrail.y = y then return Null

		local obj:TMouseAction = new TMouseAction
		obj.x = x
		obj.y = y
		obj.kind = kind

		if kind = 1 then lastTrail = obj

		list.AddLast(obj)
		return obj
	End Function

	Method Draw(previous:TMouseAction)
		if kind = 1 'mouse trail
			if previous
				DrawLine(previous.x, previous.y, x, y)
			else
				Plot(x, y)
			endif
		elseif kind = 2 'clicks
			SetColor 100,100,150
			DrawOval(x-10, y-10, 20,20)
			DrawText ("Click", x-10,y-24)
		elseif kind = 3 'long clicks
			SetColor 100,150,150
			DrawOval(x-8, y-8, 16,16)
			DrawText ("Long", x-45,y-4)
		elseif kind = 4 'double clicks
			SetColor 150,100,150
			DrawOval(x-6, y-6, 12,12)
			DrawText ("Dbl", x+20,y-4)
		elseif kind = 5 'hits
			SetColor 100,150,100
			DrawOval(x-4, y-4, 8,8)
			DrawText ("Hit", x-9,y+12)
		endif
		SetColor 255,255,255
	End Method

	Function DrawAll()
		local previousTrail:TMouseAction
		For local a:TMouseAction = Eachin list
			a.Draw(previousTrail)
			if a.kind = 1 then previousTrail = a
		Next
	End Function

	Function UpdateAll()
		While list.Count() > 100
			list.RemoveFirst()
		Wend
	End Function
End Type