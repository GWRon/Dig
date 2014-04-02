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