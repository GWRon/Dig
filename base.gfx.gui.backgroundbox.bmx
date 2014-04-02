Rem
	===========================================================
	GUI Backgroundbox
	===========================================================
End Rem
SuperStrict
Import "base.gfx.gui.bmx"
Import "base.gfx.gui.label.bmx"
Import "base.util.registry.spriteloader.bmx"




Type TGUIBackgroundBox Extends TGUIobject
	Field sprite:TSprite
	Field spriteAlpha:Float = 1.0
	Field spriteBaseName:String = "gfx_gui_panel"


	Method Create:TGUIBackgroundBox(position:TPoint, dimension:TPoint, limitState:String="")
		Super.CreateBase(position, dimension, limitState)

		SetZindex(0)
		SetOption(GUI_OBJECT_CLICKABLE, False) 'by default not clickable


		GUIManager.Add(Self)

		Return Self
	End Method


	'private getter
	'acts as cache
	Method _GetSprite:TSprite()
		'refresh cache if not set or wrong sprite name
		if not sprite or sprite.GetName() <> spriteBaseName
			sprite = GetSpriteFromRegistry(spriteBaseName)
		endif
		return sprite
	End Method


	Method DrawBackground:Int()
		Local drawPos:TPoint = GetScreenPos()
		local oldCol:TColor = new TColor.Get()

		SetAlpha oldCol.a * spriteAlpha
		_GetSprite().DrawArea(drawPos.getX(), drawPos.getY(), GetScreenWidth(), GetScreenHeight())

		oldCol.SetRGBA()
	End Method


	Method Update:Int()
		UpdateChildren()

		Super.Update()
	End Method


	Method Draw()
		DrawBackground()
		DrawChildren()
	End Method
End Type
