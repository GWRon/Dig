SuperStrict
Import BRL.PNGLoader
Import "base.util.registry.bmx"
Import "base.util.registry.imageloader.bmx"

'register this loader
new TRegistrySpriteLoader.Init()


'===== LOADER IMPLEMENTATION =====
'loader caring about "<sprite>"-types
Type TRegistrySpriteLoader extends TRegistryImageLoader
	Method Init:Int()
		name = "Sprite"
		'we also load each image as sprite
		resourceNames = "sprite|spritepack|image"
		if not registered then Register()
	End Method


	'creates - modifies default resource
	Method CreateDefaultResource:Int()
		local img:TImage = TImage(GetRegistry().GetDefault("image"))
		if not img then return FALSE

		local sprite:TSprite = new TSprite.InitFromImage(img, "defaultsprite")
		'try to find a nine patch pattern
		sprite.EnableNinePatch()

		GetRegistry().SetDefault("sprite", sprite)
		GetRegistry().SetDefault("spritepack", sprite.parent)
	End Method


	'override image config loader - to add children (sprites) support
	Method GetConfigFromXML:TData(loader:TRegistryLoader, node:TxmlNode)
		local data:TData = Super.GetConfigFromXML(loader, node)

		'are there sprites defined ("children")
		Local childrenNode:TxmlNode = TXmlHelper.FindChild(node, "children")
		If not childrenNode then return data

		local childrenData:TData[]

		For Local childNode:TxmlNode = EachIn TXmlHelper.GetNodeChildElements(childrenNode)
			'load child config into a new data
			local childData:TData = new TData
			local fieldNames:String[]
			fieldNames :+ ["name"]
			fieldNames :+ ["x", "y", "w", "h"]
			fieldNames :+ ["offsetLeft", "offsetTop", "offsetRight", "offsetBottom"]
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
		resourceName = resourceName.ToLower()

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

		'Print "LoadSpritePackResource: "+data.GetString("name") + " ["+url+"]"
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
			'search for ninepatch
			if childData.GetBool("ninepatch")
				sprite.EnableNinePatch()
			endif

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