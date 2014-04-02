Rem
	===========================================================
	Rectangle Class
	===========================================================
End Rem
SuperStrict
Import "base.util.point.bmx"


Type TRectangle {_exposeToLua="selected"}
	Field position:TPoint {_exposeToLua}
	Field dimension:TPoint {_exposeToLua}


	Method Init:TRectangle(x:Float=0, y:Float=0, w:float=0, h:float=0)
		position = new TPoint.Init(x, y)
		dimension = new TPoint.Init(w, h)
		return self
	End Method


	Method Copy:TRectangle()
		return new TRectangle.Init(position.x, position.y, dimension.x, dimension.y)
	End Method


	'returns if the rect overlaps with the gien one
	Method Intersects:int(rect:TRectangle) {_exposeToLua}
		return ( containsXY( rect.GetX(), rect.GetY() ) ..
		         OR containsXY( rect.GetX() + rect.GetW(),  rect.GetY() + rect.GetH() ) ..
		       )
	End Method


	'global helper variables should be faster than allocating locals each time (in huge amount)
	global ix:float,iy:float,iw:float,ih:float
	'get intersecting rectangle
	Method IntersectRect:TRectangle(rectB:TRectangle) {_exposeToLua}
		ix = max(GetX(), rectB.GetX())
		iy = max(GetY(), rectB.GetY())
		iw = min(GetX2(), rectB.GetX2() ) - ix
		ih = min(GetY2(), rectB.GetY2() ) - iy

		local intersect:TRectangle = new TRectangle.Init(ix,iy,iw,ih)

		if iw > 0 AND ih > 0 then return intersect
		return Null
	End Method


	'does the point overlap?
	Method ContainsPoint:int(point:TPoint) {_exposeToLua}
		return containsXY( point.GetX(), point.GetY() )
	End Method


	'does the point overlap?
	Method ContainsRect:int(rect:TRectangle) {_exposeToLua}
		return containsXY(rect.GetX(), rect.GetY()) And containsXY(rect.GetX2(), rect.GetY2())
	End Method


	Method ContainsX:int(x:float) {_exposeToLua}
		return (x >= GetX() And x < GetX2())
	End Method


	Method ContainsY:int(y:float) {_exposeToLua}
		return (y >= GetY() And y < GetY2() )
	End Method


	'does the rect overlap with the coordinates?
	Method ContainsXY:int(x:float, y:float) {_exposeToLua}
		return (    x >= GetX() And x < GetX2() ..
		        And y >= GetY() And y < GetY2() ..
		       )
	End Method


	Method MoveXY:int(x:float,y:float)
		position.MoveXY(x, y)
	End Method


	'rectangle names
	Method setXYWH(x:float, y:float, w:float, h:float)
		position.setXY(x,y)
		dimension.setXY(w,h)
	End Method


	Method GetX:float()
		return position.GetX()
	End Method


	Method GetY:float()
		return position.GetY()
	End Method


	Method GetX2:float()
		return position.GetX() + dimension.GetX()
	End Method


	Method GetY2:float()
		return position.GetY() + dimension.GetY()
	End Method


	Method GetW:float()
		return dimension.GetX()
	End Method


	Method GetH:float()
		return dimension.GetY()
	End Method


	'setter when using "sides" insteadsof coords
	Method setTLBR(top:float, left:float, bottom:float, right:float)
		position.setXY(top, left)
		dimension.setXY(bottom, right)
	End Method


	Method SetTop:int(value:float)
		position.SetX(value)
	End Method


	Method SetLeft:int(value:float)
		position.SetY(value)
	End Method


	Method SetBottom:int(value:float)
		dimension.SetX(value)
	End Method


	Method SetRight:int(value:float)
		dimension.SetY(value)
	End Method


	Method GetTop:float()
		return position.GetX()
	End Method


	Method GetLeft:float()
		return position.GetY()
	End Method


	Method GetBottom:float()
		return dimension.GetX()
	End Method


	Method GetRight:float()
		return dimension.GetY()
	End Method


	Method GetAbsoluteCenterPoint:TPoint()
		return new TPoint.Init(GetX() + GetW()/2, GetY() + GetH()/2)
	End Method


	Method Compare:Int(otherObj:Object)
		Local rect:TRectangle = TRectangle(otherObj)
		If rect.dimension.y*rect.dimension.x < dimension.y*dimension.x then Return -1
		If rect.dimension.y*rect.dimension.x > dimension.y*dimension.x then Return 1
		Return 0
	End Method

Rem
	Method Render:int()
		DrawRect(GetX(), GetY(), GetW(), GetH())
	End Method
EndRem
End Type