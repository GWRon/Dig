Rem
	====================================================================
	SpriteEntityLoader extension for Registry utility
	====================================================================

	Allows loading of "spriteEntities" in config files.

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
Import BRL.PNGLoader
Import "base.util.registry.bmx"
Import "base.util.registry.spriteloader.bmx"
Import "base.util.registry.spriteframeanimationloader.bmx"
Import "base.framework.entity.spriteentity.bmx"

'register this loader
new TRegistrySpriteEntityLoader.Init()


'===== LOADER IMPLEMENTATION =====
'loader caring about "<spriteentity>"-types
Type TRegistrySpriteEntityLoader extends TRegistryBaseLoader
	Field _createdDefaults:int = FALSE

	Method Init:Int()
		name = "SpriteEntity"
		resourceNames = "spriteEntity"
		if not registered then Register()
	End Method


	'creates - modifies default resource
	Method CreateDefaultResource:Int()
		local sprite:TSprite = TSprite(GetRegistry().GetDefault("sprite"))
		if not sprite then return FALSE

		local spriteEntity:TSpriteEntity = new TSpriteEntity.Init(sprite)
		GetRegistry().SetDefault("spriteentity", spriteEntity)

		_createdDefaults = TRUE
	End Method


	Method GetNameFromConfig:String(data:TData)
		return data.GetString("name","unknown spriteentity")
	End Method


	Method GetConfigFromXML:TData(loader:TRegistryLoader, node:TxmlNode)
		local data:TData = new TData

		local fieldNames:String[]
		fieldNames :+ ["name", "id", "guid", "spriteName"]
		fieldNames :+ ["x", "y", "w", "h"]
		'only of interest for CHILDREN
		fieldNames :+ ["offsetLeft", "offsetTop", "offsetRight", "offsetBottom"]
		TXmlHelper.LoadValuesToData(node, data, fieldNames)


		'check if a sprite gets defined within the <spriteentity> set
		local spriteNode:TxmlNode = TXmlHelper.FindChild(node, "sprite")
		if spriteNode
			'try to find a loader for "sprite" setups
			local spriteLoader:TRegistryBaseLoader = TRegistryLoader.GetResourceLoader("sprite")
			if spriteLoader
				local spriteConfig:TData = spriteLoader.GetConfigFromXML(loader, spriteNode)
				local spriteName:String = spriteLoader.GetNameFromConfig(spriteConfig)

				'store the new spriteName + spriteConfig in the child
				if spriteConfig
					local spriteName:string = spriteLoader.GetNameFromConfig(spriteConfig)
					'if there is a sprite, override "spriteName" with
					'the name of the sprite
					if spriteName then data.AddString("spriteName", spriteName)
					data.Add("spriteConfig", spriteConfig)
				endif
			endif
		endif


		'are there child entities defined?
		Local childrenNode:TxmlNode = TXmlHelper.FindChild(node, "children")
		If childrenNode
			local childrenData:TData[]
			For Local childNode:TxmlNode = EachIn TXmlHelper.GetNodeChildElements(childrenNode)
				'recursively load child config into a new data
				local childData:TData = GetConfigFromXML(loader, childNode)

				'add child data
				childrenData :+ [childData]
			Next
			if len(childrenData)>0 then data.Add("childrenData", childrenData)
		endif


		'animation configuration contained?
		local frameAnimationsNode:TxmlNode = TXmlHelper.FindChild(node, "spriteframeanimations")
		if frameAnimationsNode
			'try to find a loader for "frameanimations" setups
			local animationsLoader:TRegistryBaseLoader = TRegistryLoader.GetResourceLoader("spriteframeanimations")
			if animationsLoader
				local animationsConfig:TData = animationsLoader.GetConfigFromXML(loader, frameAnimationsNode)

				if animationsConfig then data.Add("frameAnimations", animationsConfig)
			endif
		endif
		return data
	End Method


	Method LoadFromConfig:TSpriteEntity(data:TData, resourceName:string)
		'check if we need to load a sprite first
		local spriteName:string = data.GetString("spriteName")
		local spriteConfig:TData = TData(data.Get("spriteconfig"))
		if spriteName and spriteConfig
			'try to find a loader for "sprite" setups
			'local spriteLoader:TRegistryBaseLoader = TRegistryLoader.GetResourceLoader("sprite")

			local sprite:TSprite = GetSpriteFromRegistry(spriteName, null)
			if not sprite OR sprite = GetRegistry().GetDefault("sprite")
				'a) load later
				TRegistryLoader.AddLazyLoadedResource(spriteName, "sprite", spriteConfig)
				'b) load now
				'local sprite:TSprite = TSprite(spriteLoader.LoadFromConfig(spriteConfig, "sprite"))

				'cannot load this entity until sprite exists
				return Null
			endif
		endif


		'loads entity + children
		local spriteEntity:TSpriteEntity = TSpriteEntity.InitFromConfig(data)
		if not spriteEntity then return Null
		'add to registry
		GetRegistry().Set(spriteEntity.name, spriteEntity)

		'add children to global registry too 
		For local child:TSpriteEntity = eachin spriteEntity.childSpriteEntities
			GetRegistry().Set(child.name, child)
		Next

		'indicate that the loading was successful
		return spriteEntity
	End Method
End Type


'===== CONVENIENCE REGISTRY ACCESSORS =====
Function GetSpriteEntityFromRegistry:TSpriteEntity(name:string, defaultNameOrSpriteEntity:object = Null)
	Return TSpriteEntity( GetRegistry().Get(name, defaultNameOrSpriteEntity, "spriteentity") )
End Function


Function GetSpriteEntityGroupFromRegistry:TSpriteEntity[](baseName:string, defaultNameOrSpriteEntity:object = Null)
	local spriteEntity:TSpriteEntity
	local result:TSpriteEntity[]
	local number:int = 1
	local maxNumber:int = 1000
	repeat
		'do not use "defaultType" or "defaultObject" - we want to know
		'if there is an object with this name
		spriteEntity = TSpriteEntity( GetRegistry().Get(baseName+number) )
		number :+1

		if spriteEntity then result :+ [spriteEntity]
	until spriteEntity = null or number >= maxNumber

	'add default one if nothing was found 
	if result.length = 0 and defaultNameOrSpriteEntity <> null
		if TSpriteEntity(defaultNameOrSpriteEntity)
			result :+ [TSpriteEntity(defaultNameOrSpriteEntity)]
		elseif string(defaultNameOrSpriteEntity) <> ""
			spriteEntity = TSpriteEntity( GetRegistry().Get(string(defaultNameOrSpriteEntity), null, "spriteentity") )
			if spriteEntity then result :+ [spriteEntity]
		endif
	endif


	Return result
End Function