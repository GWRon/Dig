Rem
	===========================================================
	GUI Button
	===========================================================
End Rem
SuperStrict
Import "base.gfx.gui.bmx"
Import "base.gfx.gui.label.bmx"
Import "base.util.registry.spriteloader.bmx"



Type TGUIButton Extends TGUIobject
	Field manualState:Int = 0
	Field spriteName:String = "gfx_gui_button.default"
	Field caption:TGUILabel	= Null
	Field captionArea:TRectangle = null
	Field autoSizeModeWidth:int = 0
	Field autoSizeModeHeight:int = 0

	Global AUTO_SIZE_MODE_TEXT:int = 0
	Global AUTO_SIZE_MODE_SPRITE:int = 1
	Global _typeDefaultFont:TBitmapFont


	Method Create:TGUIButton(pos:TPoint, dimension:TPoint, value:String, State:String = "")
		'setup base widget
		Super.CreateBase(pos, dimension, State)

		SetZindex(10)
		SetValue(value)

    	GUIManager.Add(Self)
		Return Self
	End Method


	Method RepositionCaption:Int()
		if not caption then return FALSE

		'resize to button dimension
		if captionArea
			local newX:Float = captionArea.position.GetX()
			local newY:Float = captionArea.position.GetY()
			local newDimX:Float = captionArea.dimension.GetX()
			local newDimY:Float = captionArea.dimension.GetX()
			'use parent values
			if newX = -1 then newX = 0
			if newY = -1 then newY = 0
			'take all the space left
			if newDimX = -1 then newDimX = rect.dimension.GetX() - newX
			if newDimX = -1 then newDimY = rect.dimension.GetY() - newY

			caption.rect.position.SetX(newX)
			caption.rect.position.SetX(newY)
			caption.rect.dimension.SetX(newDimX)
			caption.rect.dimension.SetY(newDimY)
		else
			caption.rect.position.SetXY(0, 0)
			caption.rect.dimension.CopyFrom(rect.dimension)
		endif
	End Method


	'override resize to add autocalculation and caption handling
	Method Resize(w:Float=Null,h:Float=Null)
		'autocalculate width/height
		if w = -1
			if autoSizeModeWidth = AUTO_SIZE_MODE_TEXT
				w = GetFont().getWidth(self.value) + 8
			elseif autoSizeModeWidth = AUTO_SIZE_MODE_SPRITE
				w = GetSpriteFromRegistry(spriteName).area.GetW()
			endif
		endif
		if h = -1
			if autoSizeModeHeight = AUTO_SIZE_MODE_TEXT
				h = GetFont().GetMaxCharHeight()
			'elseif autoSizeModeHeight = AUTO_SIZE_MODE_SPRITE
			'	h = GetSpriteFromRegistry(spriteName).area.GetH()
			endif

			'if height is less then sprite height (the "minimum")
			'use this
			h = Max(h, GetSpriteFromRegistry(spriteName).area.GetH())
		endif


		If w Then rect.dimension.setX(w)
		If h Then rect.dimension.setY(h)

		'move caption according to its rules
		RepositionCaption()
	End Method


	Method SetAutoSizeMode(modeWidth:int = 0, modeHeight:int = 0)
		autoSizeModeWidth = modeWidth
		autoSizeModeHeight = modeHeight
		Resize(-1,-1)
	End Method


	'override default - to use caption instead of value
	Method SetValue:Int(value:string)
		SetCaption(value)
	End Method


	Method SetCaption:Int(text:String, color:TColor=Null)
		if not caption
			'caption area starts at top left of button
			caption = New TGUILabel.Create(null, text, color, null)
			caption.SetContentPosition(ALIGN_CENTER, ALIGN_CENTER)
			'we want to manage it...
			GUIManager.Remove(caption)

			'reposition the caption
			RepositionCaption()

			'set to use the buttons font
			caption.SetFont(GetFont())
			'assign button as parent of caption
			caption.SetParent(self)
		elseif caption.value <> text
			caption.SetValue(text)
		endif

		If color Then caption.color = color
	End Method


	Method SetCaptionOffset:Int(x:int = -1, y:int = -1)
		if not captionArea then captionArea = new TRectangle
		captionArea.position.SetXY(x,y)
	End Method



	Function SetTypeFont:Int(font:TBitmapFont)
		_typeDefaultFont = font
	End Function


	'override in extended classes if wanted
	Function GetTypeFont:TBitmapFont()
		return _typeDefaultFont
	End Function


	Method GetSpriteName:String()
		return spriteName
	End Method


	Method SetCaptionAlign(alignType:String = "LEFT", valignType:String = "CENTER")
		if not caption then return

		'by default labels have left aligned content
		Select aligntype.ToUpper()
			case "CENTER" 	caption.SetContentPosition(ALIGN_LEFT, caption.contentPosition.y)
			case "RIGHT" 	caption.SetContentPosition(ALIGN_RIGHT, caption.contentPosition.y)
			default		 	caption.SetContentPosition(ALIGN_CENTER, caption.contentPosition.y)
		End Select
	End Method


	Method DrawContent:Int(position:TPoint)
		if not caption then return FALSE

		'move caption
		if state = ".active" then caption.rect.position.MoveXY(1,1)

		caption.Draw()

		'move caption back
		if state = ".active" then caption.rect.position.MoveXY(-1,-1)
	End Method


	Method Draw:Int()
		Local atPoint:TPoint = GetScreenPos()
		Local oldCol:TColor = new TColor.Get()

		SetColor 255, 255, 255
		SetAlpha oldCol.a * alpha

		Local sprite:TSprite = GetSpriteFromRegistry(GetSpriteName() + state, spriteName)
		if sprite
			'no active image available (when "mousedown" over widget)
			if state = ".active" and (sprite.name = spriteName or sprite.name="defaultsprite")
				sprite.DrawArea(atPoint.getX()+1, atPoint.getY()+1, rect.GetW(), rect.GetH())
			else
				sprite.DrawArea(atPoint.getX(), atPoint.getY(), rect.GetW(), rect.GetH())
			endif
		endif

		'draw label/caption of button
		DrawContent(atPoint)

		oldCol.SetRGBA()
	End Method
End Type
