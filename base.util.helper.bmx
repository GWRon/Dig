SuperStrict
Import brl.Reflection
Import "base.util.input.bmx" 		'Mousemanager
Import "base.util.rectangle.bmx"	'TRectangle

'collection of useful functions
Type THelper
	'check whether a checkedObject equals to a limitObject
	'1) is the same object
	'2) is of the same type
	'3) is extended from same type
	Function ObjectsAreEqual:int(checkedObject:object, limit:object)
		'one of both is empty
		if not checkedObject then return FALSE
		if not limit then return FALSE
		'same object
		if checkedObject = limit then return TRUE

		'check if classname / type is the same (type-name given as limit )
		if string(limit)<>null
			local typeId:TTypeId = TTypeId.ForName(string(limit))
			'if we haven't got a valid classname
			if not typeId then return FALSE
			'if checked object is same type or does extend from that type
			if TTypeId.ForObject(checkedObject).ExtendsType(typeId) then return TRUE
		endif

		return FALSE
	End Function


	'returns whether the mouse is within the given rectangle coords
	Function MouseIn:int(x:float,y:float,w:float,h:float)
		return IsIn(MouseManager.x, MouseManager.y, x,y,w,h)
	End Function


	'returns whether the mouse is within the given rectangle
	Function MouseInRect:int(rect:TRectangle)
		return IsIn(MouseManager.x, MouseManager.y, rect.position.x,rect.position.y,rect.dimension.x, rect.dimension.y)
	End Function


	'returns whether two pairs of "start-end"-values intersect
	Function DoMeet:int(startA:float, endA:float, startB:float, endB:float)
		'DoMeet - 4 possibilities - but only 2 for not meeting
		' |--A--| .--B--.    or   .--B--. |--A--|
		return  not (Max(startA,endA) < Min(startB,endB) or Min(startA,endA) > Max(startB, endB) )
	End function


	'returns whether the given x,y coordinate is within the given rectangle coords
	Function IsIn:Int(x:Float, y:Float, rectx:Float, recty:Float, rectw:Float, recth:Float)
		If x >= rectx And x<=rectx+rectw And..
		   y >= recty And y<=recty+recth
			Return 1
		Else
			Return 0
		End If
	End Function


	Function GetTweenedValue:float(currentValue:float, oldValue:float, tween:Float, avoidShaking:int=TRUE)
		local result:float = currentValue * tween + oldValue * (1.0 - tween)
		if avoidShaking and Abs(result - currentValue) < 0.1 then return currentValue
		return result
	End Function


	Function GetTweenedPoint:TPoint(currentPoint:TPoint, oldPoint:TPoint, tween:Float, avoidShaking:int=TRUE)
		return new TPoint.Init(..
	         GetTweenedValue(currentPoint.x, oldPoint.x, tween, avoidShaking),..
	         GetTweenedValue(currentPoint.y, oldPoint.y, tween, avoidShaking)..
	       )
	End Function
End Type