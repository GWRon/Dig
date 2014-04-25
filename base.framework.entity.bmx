SuperStrict
Import "base.util.point.bmx"
Import "base.util.deltatimer.bmx"


Type TStaticEntity
	Field position:TPoint = new TPoint
	Field name:string
	Field visible:int = True


	Method New()
		name = "TStaticEntity"
	End Method


	Method Render:Int(xOffset:Float=0, yOffset:Float=0) abstract


	Method Update:Int()
	'do nothing
	End Method


	Method IsVisible:int()
		return visible
	End Method


	Method ToString:String()
		return name
	End Method
End Type



Type TEntity extends TStaticEntity
	'for tweening
	Field oldPosition:TPoint = new TPoint
	'moving direction
	Field velocity:TPoint = new TPoint


	Method New()
		name = "TEntity"
	End Method


	Method SetVelocity(dx:float, dy:float)
		velocity.SetXY(dx, dy)
	End Method


	Method Update:Int()
		local deltaTime:Float = GetDeltaTimer().GetDelta()

		'=== UPDATE MOVEMENT ===
		'backup for tweening
		oldPosition.SetXY(position.x, position.y)
		'set new position
		position.MoveXY( deltaTime * velocity.x, deltaTime * velocity.y )
	End Method
End Type