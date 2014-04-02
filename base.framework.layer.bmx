Rem
	====================================================================
	Layer class + Layermanager class
	====================================================================

	Code contains following classes:
	TLayerManager: basic layer manager (Set, Get)
	TLayer: basic layer with possiblity to hold (static) renderables


	====================================================================
	LICENCE

	Copyright (C) 2002-2014 Ronny Otto, digidea.de

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
Import "base.gfx.renderable.bmx"
Import BRL.Map

Type TLayerManager
	Field layers:TMap = CreateMap()
	global _instance:TLayerManager


	Method New()
		if _instance Then Throw "Multiple TLayerManager not allowed"
		_instance = self
	End Method


	Function GetInstance:TLayerManager()
		If not _instance Then New TLayerManager
		Return _instance
	End Function


	'adds a layer
	'overwrites an existing layers with same name
	Method Set:int(key:String, layer:TLayer)
		layers.Insert(key.ToUpper(), layer)
	End Method


	Method Get:TLayer(name:String)
		return TLayer(layers.ValueForKey(name.ToUpper()))
	End Method
End Type




Type TLayer
	Field name:String
	Field zIndex:Int
	Field objects:TMap = CreateMap()


	Method AddObject:int(obj:TRenderable)
		objects.insert(obj.name.ToUpper(), obj)
	End Method


	Method GetObject:TRenderable(name:string)
		return TRenderable(objects.ValueForKey(name.ToUpper()))
	End Method


	'sort layers according zIndex
	Method Compare:Int(other:Object)
		Local otherLayer:TLayer = TLayer(other)
		'no weighting
		If Not otherLayer then Return 0
		If otherLayer = Self then Return 0
		If otherLayer.zIndex = zIndex Then Return 0
		'below me
		If otherLayer.zIndex < zIndex Then Return 1
		'on top of me
		Return -1
	End Method


	Method Render:Int(xOffset:Float=0, yOffset:Float=0)
		For Local obj:TRenderable = Eachin objects
			'skip invisble objects
			If not obj.visible Then continue

			obj.Render(xOffset, yOffset)
		Next
	End Method
End Type