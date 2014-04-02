SuperStrict
Import BRL.PNGLoader
Import "base.util.registry.bmx"

'register this loader
new TRegistryFontLoader.Init()


'===== LOADER IMPLEMENTATION =====
'loader caring about "<font>"-types (and "<fonts>"-groups)
Type TRegistryFontLoader extends TRegistryBaseLoader
	Method Init:Int()
		name = "Font"
		'we also load each image as sprite
		resourceNames = "font|fonts"
		if not registered then Register()
	End Method


	'creates - modifies default resource
	Method CreateDefaultResource:Int()
		'
		'hier fontmanager-default font ueberschreiben ?!
	End Method


	'override image config loader - to add children (sprites) support
	Method GetConfigFromXML:TData(loader:TRegistryLoader, node:TxmlNode)
		local data:TData = Super.GetConfigFromXML(loader, node)

		'=== HANDLE "<FONTS>" ===
		Local nodeTypeName:String = TXmlHelper.FindValue(node, "name", node.GetName())
		if nodeTypeName.toLower() = "fonts"
			Local childrenNode:TxmlNode = TXmlHelper.FindChild(node, "font")
			For Local childNode:TData = EachIn childrenNode
				local childData:TData = GetConfigFromXML(loader, childNode)
				'skip invalid configurations
				if not childData then continue

				'add each font to "ToLoad"-list
				local resName:string = loader.GetNameFromConfig(childConf)
				TRegistryUnloadedResourceCollection.GetInstance().Add(..
					new TRegistryUnloadedResource.Init(childName, resName, childConf)..
				)
			Next
			return Null
		endif



		'=== HANDLE "<FONT>" ===
		Local name:String	= Lower( xmlLoader.xml.FindValue(childNode, "name", "") )
		Local url:String	= xmlLoader.xml.FindValue(childNode, "url", "")
		Local size:Int		= xmlLoader.xml.FindValueInt(childNode, "size", 10)
		Local setDefault:Int= xmlLoader.xml.FindValueInt(childNode, "default", 0)

		url = xmlLoader.ConvertURI(url)

		Local flags:Int = 0
		Local flagsstring:String = xmlLoader.xml.FindValue(childNode, "flags", "")
		If flagsstring <> ""
			Local flagsarray:String[] = flagsstring.split(",")
			For Local flag:String = EachIn flagsarray
				flag = Upper(flag.Trim())
				If flag = "BOLDFONT" Then flags = flags + BOLDFONT
				If flag = "ITALICFONT" Then flags = flags + ITALICFONT
			Next
		EndIf

		If name="" Or url="" Then Return 0
		Local font:TGW_BitmapFont = Assets.fonts.AddFont(name, url, size, SMOOTHFONT +flags)

		If setDefault
			If flags & BOLDFONT
				Assets.fonts.baseFontBold = font
			ElseIf flags & ITALICFONT
				Assets.fonts.baseFontItalic = font
			ElseIf name = "smalldefault"
				Assets.fonts.baseFontSmall = font
			Else
				Assets.fonts.baseFont = font
			EndIf
		EndIf



		Local childrenNode:TxmlNode = TXmlHelper.FindChild(node, "font")
		Local childrenNode:TxmlNode = TXmlHelper.FindChild(node, "children")
		If not childrenNode then return data

		local childrenData:TData[]
		For Local childNode:TxmlNode = EachIn childrenNode
			If childNode.getType() <> XML_ELEMENT_NODE Then Continue

			'load child config into a new data
			local childData:TData = new TData
			local fieldNames:String[]
			fieldNames :+ ["name"]
			fieldNames :+ ["x", "y", "w", "h"]
			fieldNames :+ ["offsetTop", "offsetLeft", "offsetBottom", "offsetRight"]
			fieldNames :+ ["frames|f"]
			fieldNames :+ ["ninepatch"]
			TXmlHelper.LoadValuesToData(childNode, childData, fieldNames)
			'add script data
			childrenData :+ [childData]
		Next
		if len(childrenData)>0 then data.Add("childrenData", childrenData)

		return data
	End Method


	Method LoadFromConfig:int(data:TData, resourceName:string)
		if resourceName = "sprite" then return LoadSpriteFromConfig(data)

		'also create sprites from images
		if resourceName = "image" then return LoadSpriteFromConfig(data)

		if resourceName = "spritepack" then return LoadSpritePackFromConfig(data)
	End Method


	Method LoadSpriteFromConfig:Int(data:TData)
		'create spritepack (name+"_pack") and sprite (name)
		local sprite:TSprite = new TSprite.InitFromConfig(data)
		if not sprite then return FALSE

		'colorize if needed
		If data.GetInt("r",-1) >= 0 And data.GetInt("g",-1) >= 0 And data.GetInt("r",-1) >= 0
			sprite.colorize( TColor.Create(data.GetInt("r"), data.GetInt("g"), data.GetInt("b")) )
		Endif

		'add to registry
		GetRegistry().Set(data.GetString("name"), sprite)
	End Method


	Method LoadSpritePackFromConfig:Int(data:TData)
		local url:string = data.GetString("url")
		if url = "" then return FALSE

		'Print "LoadSpritePackResource: "+_name + " " + _flags + " ["+url+"]"
		Local img:TImage = LoadImage(url, data.GetInt("flags", 0))
		Local spritePack:TSpritePack = new TSpritePack.Init(img, data.GetString("name"))
		'add spritepack to asset
		GetRegistry().Set(spritePack.name, spritePack)

		'add children
		local childrenData:TData[] = TData[](data.Get("childrenData"))

		For local childData:TData = eachin childrenData
			Local sprite:TSprite = new TSprite
			sprite.Init( ..
				spritePack, ..
				childData.GetString("name"), ..
				new TRectangle.Init( ..
					childData.GetInt("x"), ..
					childData.GetInt("y"), ..
					childData.GetInt("w"), ..
					childData.GetInt("h") ..
				), ..
				new TRectangle.Init( ..
					childData.GetInt("offsetTop"), ..
					childData.GetInt("offsetLeft"), ..
					childData.GetInt("offsetBottom"), ..
					childData.GetInt("offsetRight") ..
				), ..
				childData.GetInt("frames") ..
			)
			'try to enable ninePatch (read borders)
			sprite.EnableNinePatch()

			'recolor/colorize?
			If childData.GetInt("r",-1) >= 0 And childData.GetInt("g",-1) >= 0 And childData.GetInt("b",-1) >= 0
				sprite.colorize( TColor.Create(childData.GetInt("r",-1),childData.GetInt("g",-1),childData.GetInt("b",-1)) )
			endif

			spritePack.addSprite(sprite)
			GetRegistry().Set(childData.GetString("name"), sprite)
		Next
	End Method
End Type


'===== CONVENIENCE REGISTRY ACCESSORS =====
Function GetSpriteFromRegistry:TSprite(name:string, defaultNameOrSprite:object = Null)
	Return TSprite( GetRegistry().Get(name, defaultNameOrSprite, "sprite") )
End Function