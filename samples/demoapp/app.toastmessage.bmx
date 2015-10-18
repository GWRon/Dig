SuperStrict

Import "../../base.framework.toastmessage.bmx"
Import "../../base.util.registry.spriteloader.bmx"
Import "app.world.worldtime.bmx"


Type TAppToastMessage Extends TToastMessage
	Field backgroundSprite:TSprite
	Field messageType:Int = 0
	Field caption:String = ""
	Field text:String = ""
	'the higher the more important the message is
	Field priority:Int = 0
	Field showBackgroundSprite:Int = True
	'an array containing registered event listeners
	Field _registeredEventListener:TLink[]
	Field _closeAtWorldTime:Double = -1
	Field _closeAtWorldTimeText:String = "closing at %TIME%"


	Method New()
		area.dimension.SetXY(250,50)
	End Method


	Method Remove:Int()
		For Local link:TLink = EachIn _registeredEventListener
			link.Remove()
		Next
		Super.Remove()
	End Method
	

	Method SetMessageType:Int(messageType:Int)
		Self.messageType = messageType

		Select messageType
			Case 0
				Self.backgroundSprite = GetSpriteFromRegistry("gfx_toastmessage.info")
			Case 1
				Self.backgroundSprite = GetSpriteFromRegistry("gfx_toastmessage.attention")
			Case 2
				Self.backgroundSprite = GetSpriteFromRegistry("gfx_toastmessage.positive")
			Case 3
				Self.backgroundSprite = GetSpriteFromRegistry("gfx_toastmessage.negative")
		EndSelect

		RecalculateHeight()
	End Method


	Method AddCloseOnEvent(eventKey:String)
		Local listenerLink:TLink = EventManager.registerListenerMethod(eventKey, Self, "onReceiveCloseEvent", Self)
		_registeredEventListener :+ [listenerLink]
	End Method


	Method onReceiveCloseEvent(triggerEvent:TEventSimple)
		Close()
	End Method


	Method SetCaption:Int(caption:String)
		Self.caption = caption
		RecalculateHeight()
	End Method


	Method SetText:Int(text:String)
		Self.text = text
		RecalculateHeight()
	End Method


	'override to add height recalculation (as a bar is drawn then)
	Method SetLifeTime:Int(lifeTime:Float = -1)
		Super.SetLifeTime(lifeTime)
		RecalculateHeight()
	End Method


	Method SetCloseAtWorldTime:Int(worldTime:Double = -1)
		_closeAtWorldTime = worldTime
		RecalculateHeight()
	End Method


	Method SetPriority:Int(priority:Int=0)
		Self.priority = priority
	End Method 


	Method RecalculateHeight:Int()
		Local height:Int = 0
		'caption singleline
		height :+ GetBitmapFontManager().baseFontBold.GetMaxCharHeight()
		'text
		height :+ GetBitmapFontManager().baseFont.GetBlockDimension(text, area.GetW(), -1).GetY()
		'gfx padding
		If showBackgroundSprite And backgroundSprite
			height :+ backgroundSprite.GetNinePatchContentBorder().GetTop()
			height :+ backgroundSprite.GetNinePatchContentBorder().GetBottom()
		EndIf
		'lifetime bar
		If _lifeTime > 0 Then height :+ 5
		'close hint
		If _closeAtWorldTime > 0 And _closeAtWorldTimeText <> ""
			height :+ GetBitmapFontManager().baseFontBold.GetMaxCharHeight()
		EndIf
		
		area.dimension.SetY(height)
	End Method


	'override to add worldTime
	Method Update:Int()
		'check if lifetime is running out - close message then
		If _closeAtWorldTime >= 0 And Not HasStatus(TOASTMESSAGE_OPENING_OR_CLOSING)
			If _closeAtWorldTime < GetWorldTime().GetTimeGone()
				close()
			EndIf
		EndIf
		
		Return Super.Update()
	End Method


	'override to draw our nice background
	Method RenderBackground:Int(xOffset:Float=0, yOffset:Float=0)
		If showBackgroundSprite
			'set type again to reload sprite
			If Not backgroundSprite Or backgroundSprite.name = "defaultsprite" Then SetMessageType(messageType)
			If backgroundSprite Then backgroundSprite.DrawArea(xOffset + GetScreenX(), yOffset + GetScreenY(), area.GetW(), area.GetH())
		EndIf
	End Method


	'override to draw our texts
	Method RenderForeground:Int(xOffset:Float=0, yOffset:Float=0)
		Local contentX:Int = xOffset + GetScreenX()
		Local contentY:Int = yOffset + GetScreenY()
		Local contentX2:Int = contentX + GetScreenWidth()
		Local contentY2:Int = contentY + GetScreenHeight()
		If showBackgroundSprite And backgroundSprite
			contentX :+ backgroundSprite.GetNinePatchContentBorder().GetLeft()
			contentY :+ backgroundSprite.GetNinePatchContentBorder().GetTop()
			contentX2 :- backgroundSprite.GetNinePatchContentBorder().GetRight()
			contentY2 :- backgroundSprite.GetNinePatchContentBorder().GetBottom()
		EndIf

		Local captionHeight:Int = GetBitmapFontManager().baseFontBold.GetMaxCharHeight()
		GetBitmapFontManager().baseFontBold.DrawBlock(caption, contentX, contentY, contentX2 - contentX, captionHeight, Null, TColor.clBlack)
		GetBitmapFontManager().baseFont.DrawBlock(text, contentX, contentY + captionHeight, contentX2 - contentX, -1, Null, TColor.CreateGrey(50))


		'worldtime close hint
		If _closeAtWorldTime > 0 And _closeAtWorldTimeText <> ""
			Local text:String = _closeAtWorldTimeText
			text = text.Replace("%H%", GetWorldTime().GetDayHour(_closeAtWorldTime))
			text = text.Replace("%I%", GetWorldTime().GetDayMinute(_closeAtWorldTime))
			text = text.Replace("%S%", GetWorldTime().GetDaySecond(_closeAtWorldTime))
			text = text.Replace("%D%", GetWorldTime().GetDay(_closeAtWorldTime))
			text = text.Replace("%Y%", GetWorldTime().GetYear(_closeAtWorldTime))
			text = text.Replace("%SEASON%", GetWorldTime().GetSeason(_closeAtWorldTime))
			text = text.Replace("%TIME%", GetWorldTime().GetFormattedTime(_closeAtWorldTime))
			
			GetBitmapFontManager().baseFontBold.DrawBlock(text, contentX, contentY2 - GetBitmapFontManager().baseFontBold.GetMaxCharHeight(), contentX2 - contentX, -1, Null, TColor.CreateGrey(50))
		EndIf
		
		'lifetime bar
		If _lifeTime > 0
			Local lifeTimeWidth:Int = contentX2 - contentX
			Local oldCol:TColor = New TColor.Get()
			lifeTimeWidth :* GetLifeTimeProgress()

			If priority <= 2
				SetAlpha oldCol.a * 0.2 + 0.05*priority
				SetColor(120,120,120)
			ElseIf priority <= 5
				SetAlpha oldCol.a * 0.3 + 0.1*priority
				SetColor(200,150,50)
			Else
				SetAlpha oldCol.a * 0.5 + 0.05*priority
				SetColor(255,80,80)
			EndIf
			'+2 = a bit of padding
			DrawRect(contentX, contentY2 - 5 + 2, lifeTimeWidth, 3)
			oldCol.SetRGBA()
		EndIf

	End Method
End Type