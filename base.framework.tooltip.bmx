Rem
	====================================================================
	class providing a graphical tooltip functionality
	====================================================================

	Basic tooltip


	====================================================================
	If not otherwise stated, the following code is available under the
	following licence:

	LICENCE: zlib/libpng

	Copyright (C) 2002-2015 Ronny Otto, digidea.de

	This software is provided 'as-is', without any express or
	implied warranty. In no event will the authors be held liable
	for any	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it
	and redistribute it freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you
	   must not claim that you wrote the original software. If you use
	   this software in a product, an acknowledgment in the product
	   documentation would be appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and
	   must not be misrepresented as being the original software.

	3. This notice may not be removed or altered from any source
	   distribution.
	====================================================================
EndRem
SuperStrict
Import "base.framework.entity.bmx"
Import "base.gfx.bitmapfont.bmx"
Import "base.util.interpolation.bmx"


Type TTooltipBase Extends TEntity
	'how long this tooltip is existing
	Field lifeTime:Float = 0.1
	'initial lifetime value
	Field startLifetime:Float = 0.1
	'current fading value (0-1.0)
	Field fadeValue:Float = 1.0
	'bool to define whether lifeTime gets lost during updates
	'if enabled, the tooltip wont fade out automatically
	Field keepAlive:int = False
	'at which lifetime fading starts
	Field startFadingTime:Float = 0.20
	Field cacheImage:TImage = Null
	Field calculatedDimension:TVec2D
	Field enabled:int = True

	Global cacheImageEnabled:Int = True


	Method Initialize:TTooltipBase(x:Int=0, y:Int=0, w:Int=-1, h:Int=-1, lifetime:Float = 1.0)
		Self.area = new TRectangle.Init(x, y, w, h)
		Self.startLifetime = lifetime
		Self.startFadingTime = Min(0.9 * startLifetime, Max(startLifetime/2.0, 0.1))
		Self.Reset()
		return self
	End Method


	'sort tooltips according lifetime (dying ones behind)
	Method Compare:Int(other:Object)
		Local otherTip:TTooltip = TTooltip(other)
		'no weighting
		If Not otherTip then Return 0
		If otherTip = Self then Return 0
		If otherTip.GetLifePercentage() = GetLifePercentage() Then Return 0
		'below me
		If otherTip.GetLifePercentage() < GetLifePercentage() Then Return 1
		'on top of me
		Return -1
	End Method


	'by default a tooltip has the size of 0
	Method RecalculateDimensions()
		if not calculatedDimension then calculatedDimension = new TVec2D
		calculatedDimension.SetXY(Max(0,area.GetW()), Max(0,area.GetH()))
	End Method


	Method Reset()
		ResetCache()
		Self.lifetime = startLifetime
		self.fadeValue  = 1.0
	End Method
	

	Method ResetCache()
		cacheImage = Null
	End method


	Method GenerateCache()
	End method


	'returns (in percents) how many lifetime is left
	Method GetLifePercentage:float()
		if startLifetime = 0 then return 1.0
		return Min(1.0, Max(0.0, lifetime / startLifetime))
	End Method


	Method GetFadeValue:float()
		return fadeValue
	End Method


	Method Die:int()
		ResetCache()
		'if IsEnabled() then SetEnabled(false)
		'if IsVisible() then SetVisible(false)
		return True
	End Method


	Method SetEnabled(bool:int = True)
		enabled = bool
	End Method


	Method IsAlive:int()
		return lifeTime > 0
	End Method


	Method IsEnabled:int()
		return enabled
	End Method
	

	'stub function, override in direct implementation
	Method IsHovered:int()
		return False
	End Method
	

	'reset lifetime
	Method Hover()
		lifeTime = startLifetime
		fadeValue = 1.0
	End Method


	Method SetKeepAlive(bool:int = True)
		keepAlive = bool
	End Method

	
	'moves tooltip  so that everything is visible on screen / given area
	Method LimitToVisibleArea(x:int, y:int, w:int, h:int)
		local outOfScreenLeft:int = Min(x, GetScreenX())
		local outOfScreenRight:int = Max(x, GetScreenX() + GetScreenWidth() - w)
		local outOfScreenTop:int = Min(y, GetScreenY())
		local outOfScreenBottom:int = Max(y, GetScreenY() + GetScreenHeight() - h)
		if outOfScreenLeft then area.position.SetX( area.GetX() + outOfScreenLeft )
		if outOfScreenRight then area.position.SetX( area.GetX() - outOfScreenRight )
		if outOfScreenTop then area.position.SetY( area.GetY() + outOfScreenTop )
		if outOfScreenBottom then area.position.SetY( area.GetY() - outOfScreenBottom )
	End Method
	

	Method GetScreenWidth:Float()
		If cacheImageEnabled and cacheImage Then Return Max(area.GetW(), cacheImage.width)

		'recalculate dimensions if needed
		If area.GetW() <= 0
			if not calculatedDimension then RecalculateDimensions()
			return calculatedDimension.x
		endif

		return Super.GetScreenWidth()
	End Method


	Method GetScreenHeight:Float()
		If cacheImageEnabled and cacheImage Then Return Max(area.GetH(), cacheImage.height)

		'recalculate dimensions if needed
		If area.GetH() <= 0
			if not calculatedDimension then RecalculateDimensions()
			return calculatedDimension.y
		endif

		return Super.GetScreenHeight()
	End Method
	

	Method GetRenderOffsetX:Float()
		return 0
	End Method

	Method GetRenderOffsetY:Float()
		return 0
	End Method


	Method UpdateFadeValue()
		'start fading if lifetime is running out (lower than fade time)
		If lifetime <= startFadingTime
			fadeValue :- GetDeltaTimer().GetDelta()
			fadeValue :* 0.8 'speed up fade
		EndIf
	End Method
	

	Method RenderCache:int(xOffset:Float = 0, yOffset:Float = 0, align:TVec2D = Null)
		if not cacheImage then return False
		if align
			DrawImage(cacheImage, xOffset + align.x * imageWidth(cacheImage), yOffset + align.y * imageHeight(cacheImage))
		else
			DrawImage(cacheImage, xOffset, yOffset)
		endif
	End Method


	Method RenderBackground:int(xOffset:Float = 0, yOffset:Float = 0, align:TVec2D = Null)
		local oldCol:TColor = new TColor.Get()

		'bright background
		SetColor 100,100,100

		'only draw rect if we got some dimensions
		local w:int = GetScreenWidth()
		local h:int = GetScreenHeight()
		if w > 0 and h > 0
			DrawRect(int(GetScreenX() + xOffset), int(GetScreenY() + yOffset), w, h)
		endif
		
		oldCol.SetRGB()
	End Method


	Method RenderForeground:int(xOffset:Float = 0, yOffset:Float = 0, align:TVec2D = Null)
	End Method


	Method Render:Int(xOffset:Float = 0, yOffset:Float=0, alignment:TVec2D = Null)
		If Not isVisible() or not isEnabled() Then Return 0
		If not isAlive() then Return 0

		xOffset :+ GetRenderOffsetX()
		yOffset :+ GetRenderOffsetY()

		If cacheImageEnabled and not cacheImage then GenerateCache()

		local col:TColor = TColor.Create().Get()
		SetAlpha col.a * GetFadeValue()
		SetColor 255,255,255

		if cacheImageEnabled and cacheImage
			RenderCache(xOffset, yOffset, alignment)
		else
			RenderBackground(xOffset, yOffset, alignment)
			RenderForeground(xOffset, yOffset, alignment)
		endif

		col.SetRGBA()

		'=== DRAW CHILDREN ===
		RenderChildren(xOffset, yOffset, alignment)
	End Method


	Method Update:Int()
		if not isEnabled() then return False
		if not isAlive() then return False

		'do not subtract lifeTime if lifeTime is set to 0 or less
		if not keepAlive and lifeTime > 0
			lifeTime :- GetDeltaTimer().GetDelta()
			If not isAlive() then Die()
		endif

		UpdateFadeValue()

		if IsHovered() then Hover()

		LimitToVisibleArea(0, 0, GraphicsWidth(), GraphicsHeight())


		'move + handle children
		Return Super.Update()
	End Method	
End Type



Type TTooltip Extends TTooltipBase
	Field caption:String
	Field captionAlign:TVec2D = new TVec2D
	Field captionColor:TColor
	Field description:String
	Field descriptionAlign:TVec2D = new TVec2D
	Field descriptionColor:TColor
	Field minDimension:TVec2D = new TVec2D
	'left (2) and right (4) is for all elements
	'top (1) and bottom (3) padding for content
	Field padding:TRectangle = new TRectangle.Init(3,3,3,3)

	Field captionFont:TBitmapFont
	Field descriptionFont:TBitmapFont

	Global typeFont:TBitmapFont
	Global defaultFont:TBitmapFont


	Method Initialize:TTooltip(x:Int=0, y:Int=0, w:Int=-1, h:Int=-1, lifeTime:Float = 1.0)
		Super.Initialize(x, y, w, h, lifeTime)

		captionAlign = ALIGN_LEFT_CENTER
		descriptionAlign = ALIGN_LEFT_TOP

		return self
	End Method


	'override
	Method ResetCache:int()
		calculatedDimension = null
		Super.ResetCache()
	End Method


	Method SetDefaultFont:int(font:TBitmapFont)
		defaultFont = font
	End Method


	Method GetDefaultFont:TBitmapFont()
		If Not defaultFont then defaultFont = GetBitmapFontManager().GetDefaultFont()
		Return defaultFont
	End Method


	Method SetFont:Int(font:TBitmapFont)
		self.typeFont = font
	End Method


	Method GetFont:TBitmapFont()
		if typeFont then return typeFont
		return GetDefaultFont()
	End Method


	Method SetCaptionFont:Int(font:TBitmapFont)
		self.captionFont = font
	End Method


	Method SetDescriptionFont:Int(font:TBitmapFont)
		self.descriptionFont = font
	End Method


	Method GetCaptionFont:TBitmapFont()
		if captionFont then return captionFont
		return GetFont()
	End Method


	Method GetDescriptionFont:TBitmapFont()
		if descriptionFont then return descriptionFont
		return GetFont()
	End Method


	Method GetDescriptionColor:TColor()
		if not descriptionColor then return TColor.clWhite
		return descriptionColor
	End Method


	Method GetCaptionColor:TColor()
		if not captionColor then return TColor.clWhite
		return captionColor
	End Method


	'override
	Method RecalculateDimensions()
		if not calculatedDimension then calculatedDimension = new TVec2D

		If cacheImageEnabled and cacheImage
			calculatedDimension.SetXY( cacheImage.width, cacheImage.height )
			Return
		EndIf

		local width:int = Max(GetContentWidth(-1), GetMinContentWidth())
		local height:int = Max(GetContentHeight(width), GetMinContentHeight())
		calculatedDimension.SetXY(..
			width + padding.GetLeft() + padding.GetRight(),..
			height + padding.GetTop() + padding.GetBottom() ..
		)
	End Method


	'minimum width-dimension of the whole content area
	Method GetMinContentWidth:int()
		return Max(0, Max(GetScreenWidth(), minDimension.x) - padding.GetLeft() - padding.GetRight())
	End Method

	'minimum height-dimension of the whole content area
	Method GetMinContentHeight:int()
		return Max(0, Max(GetScreenHeight(), minDimension.y) - padding.GetTop() - padding.GetBottom())
	End Method


	'occupied width of the whole content area
	Method GetContentWidth:int(maxHeight:int = -1)
		'use max of caption and description width
		return Max(GetCaptionWidth(), GetDataWidth())
	End Method
		
	'occupied height of the whole content area
	Method GetContentHeight:int(maxWidth:int = -1)
		Local height:Int = 0

		'height from caption + description + spacing
		height:+ getCaptionHeight()
		height:+ getDataHeight(maxWidth)

		return height
	End Method
	

	Method GetCaptionWidth:int(maxHeight:int = -1)
		local result:int = GetCaptionFont().getWidth(caption)
		'add icon to width
'		If tooltipimage >=0 Then result :+ ToolTipIcons.framew + 2

		return result
	End Method


	Method GetCaptionHeight:Int(maxWidth:int = -1)
		local result:int = GetCaptionFont().getMaxCharHeight()
'		Local result:Int = TooltipHeader.area.GetH()
		'add icon to height of caption
		'If tooltipimage >= 0 Then result :+ 2
		Return result
	End Method


	Method GetDataWidth:Int(maxHeight:int = 0)
		'only add a line if there is text
		if description <> ""
			'we cannot calculate a width for a given height that easily
			'because line breaks could force a specific minHeight
			'we could calc the minHeight using a extra high width value
			'so only line breaks are increasing the height
			'return Max(GetDescriptionFont().getBlockWidth(description, maxWidth, maxHeight), min)

			return minDimension.x
		else
			return 0
		endif
	End Method


	Method GetDataHeight:Int(maxWidth:int = 0)
		'only add a line if there is text
		If Description <> ""
			if maxWidth <= 0 then maxWidth = GetDataWidth()
			if maxWidth <= 0 then return 0
			return GetDescriptionFont().getBlockHeight(description, maxWidth, 0)
		else
			return 0
		endif
	End Method


	Method SetCaption:Int(value:String)
		if caption = value then return FALSE

		caption = value
		'force redraw/cache reset
		ResetCache()
	End Method


	Method SetCaptionAlign(align:TVec2D)
		captionAlign = align
	End Method


	Method SetDescription:Int(value:String)
		if description = value then return FALSE

		description = value
		'force redraw/cache reset
		ResetCache()
	End Method


	'override
	Method RenderBackground:int(xOffset:Float = 0, yOffset:Float = 0, align:TVec2D = Null)
		local col:TColor = TColor.Create().Get()
		local x:int = GetScreenX() + xOffset
		local y:int = GetScreenY() + yOffset

		'shadow
		SetColor 0, 0, 0
		SetAlpha col.a * 0.3 * GetFadeValue()
		DrawRect(x + 2, y + 2, GetScreenWidth(), GetScreenHeight())

		SetAlpha col.a * 0.1 * GetFadeValue()
		DrawRect(x + 1, y + 1, GetScreenWidth(), GetScreenHeight())

		col.SetRGBA()
		
		Super.RenderBackground(xOffset, yOffset, align)
	End Method


	Method RenderForeground:int(xOffset:Float = 0, yOffset:Float = 0, align:TVec2D = Null)
		local width:int = GetScreenWidth() - padding.GetLeft() - padding.GetRight()
		local height:int = GetScreenHeight() - padding.GetTop() - padding.GetRight()
		local captionHeight:int = GetCaptionHeight()
		RenderCaptionAt(GetScreenX() + xOffset + padding.GetLeft(), GetScreenY() + yOffset, width, captionHeight)

		RenderDataAt(GetScreenX() + xOffset + padding.GetLeft(), GetScreenY() + yOffset + captionHeight, width, height - captionHeight)
	End Method
	

	Method RenderCaptionAt:int(x:int, y:int, width:int, height:int)
		SetAlpha 0.5 * GetAlpha()
		SetColor 100,0,0
		DrawRect(x, y, width, height)
		SetAlpha 2.0 * GetAlpha()
		SetColor 255,255,255
		GetCaptionFont().drawBlock(caption, x, y, width, height, captionAlign, GetCaptionColor())
	End Method


	Method RenderDataAt:int(x:int, y:int, width:int, height:int)
		If description = "" then return False
			
		GetDescriptionFont().drawBlock(description, x, y, width, height, descriptionAlign, GetDescriptionColor())
	End Method
End Type




Type TTooltipHint extends TTooltip
	Global typeFont:TBitmapFont

	Method Initialize:TTooltipHint(x:Int=0, y:Int=0, w:Int=-1, h:Int=-1, lifeTime:Float = 10.0)
		Super.Initialize(x, y, w, h, lifeTime)
		return self
	End Method

	'override
	Method GetRenderOffsetY:Float()
		'local animTimeTotal:Float = 0.6
		'local animTime:Float = Abs(animTimeTotal - 2 * ((Time.GetTimeGone() mod (animTimeTotal*1000)) / 1000.0))
		'local dy:float = TInterpolation.RegularInOut(-2.0, 2.0, animTime , animTimeTotal)
		return 1.0 * Sin(Time.GetTimeGone())
		'return 0
	End Method
End Type