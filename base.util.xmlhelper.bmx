SuperStrict
Import "external/libxml/libxml.bmx"
Import "base.util.data.bmx"

Type TXmlHelper
	Field filename:string =""
	Field file:TxmlDoc
	Field root:TxmlNode


	Function Create:TXmlHelper(filename:string)
		local obj:TXmlHelper = new TXmlHelper
		obj.filename= filename
		obj.file	= TxmlDoc.parseFile(filename)
		obj.root	= obj.file.getRootElement()
		return obj
	End Function


	'find a "<tag>"-element within a given start node
	Method FindElementNode:TxmlNode(startNode:TXmlNode, nodeName:string)
		nodeName = nodeName.ToLower()
		if not startNode then startNode = root

		'return all children of the node: nodes, attributes...
		local children:TList = startNode.getChildren(XML_ELEMENT_NODE)
		if not children then return null
		For local child:TxmlNode = eachin children
			if child.getName().ToLower() = nodeName then return child
			For local subStartNode:TxmlNode = eachin child.getChildren()
				local subChild:TXmlNode = FindElementNode(subStartNode, nodeName)
				if subChild then return subChild
			Next
		Next
		return null
	End Method


	Method FindRootChild:TxmlNode(nodeName:string)
		return FindChild(root, nodeName)
	End Method


	Function findAttribute:string(node:TxmlNode, attributeName:string, defaultValue:string)
		if node.hasAttribute(attributeName) <> null then return node.getAttribute(attributeName) else return defaultValue
	End Function


	Function FindChild:TxmlNode(node:TxmlNode, nodeName:string)
		nodeName = nodeName.ToLower()
		local children:TList = node.getChildren(XML_ELEMENT_NODE)
		if not children then return null
		For local child:TxmlNode = eachin children
			if child.getName().ToLower() = nodeName then return child
		Next
		return null
	End Function


	'loads values of a node into a tdata object
	Function LoadValuesToData:int(node:TXmlNode, data:TData var, fieldNames:string[])
		For local fieldName:String = eachin fieldNames
			if not TXmlHelper.HasValue(node, fieldName) then continue
			'use the first fieldname ("frames|f" -> add as "frames")
			local names:string[] = fieldName.ToLower().Split("|")

			data.Add(names[0], FindValue(node, fieldName, ""))
		Next
	End Function


	Function HasValue:int(node:TXmlNode, fieldName:string)
		'loop through all potential fieldnames ("frames|f" -> "frames", "f")
		local fieldNames:string[] = fieldName.ToLower().Split("|")

		For local name:String = eachin fieldNames
			If node.hasAttribute(name) then Return True

			'GetChildren(0) means ALL types - instead of only "XML_TEXT_NODE"
			local children:TList = node.getChildren(XML_ELEMENT_NODE)
			if not children then continue

			For local subNode:TxmlNode = EachIn children
				if subNode.getType() = XML_TEXT_NODE then continue
				If subNode.getName().ToLower() = name then return TRUE
				If subNode.getName().ToLower() = "data" and subNode.hasAttribute(name) then Return TRUE
			Next
		Next
		return FALSE
	End Function


	'find a value within:
	'- the current NODE's attributes
	'  <obj FIELDNAME="bla" />
	'- the first level children
	'- <obj><FIELDNAME>bla</FIELDNAME><anotherfield ...></anotherfield></obj>
	Function FindValue:string(node:TxmlNode, fieldName:string, defaultValue:string, logString:string="")
		'loop through all potential fieldnames ("frames|f" -> "frames", "f")
		local fieldNames:string[] = fieldName.ToLower().Split("|")

		For local name:String = eachin fieldNames
			'given node has attribute (<episode number="1">)
			If node.hasAttribute(name) then Return node.getAttribute(name)

			'GetChildren(0) means ALL types - instead of only "XML_TEXT_NODE"
			'we want only elements "<element>"
			local children:TList = node.getChildren(XML_ELEMENT_NODE)
			if not children then continue

			For local subNode:TxmlNode = EachIn children
				If subNode.getName().ToLower() = name then return subNode.getContent()
				If subNode.getName().ToLower() = "data" and subNode.hasAttribute(name) then Return subNode.getAttribute(name)
			Next
		Next
		if logString <> "" then print logString
		return defaultValue
	End Function


	Function FindValueInt:int(node:TxmlNode, fieldName:string, defaultValue:int, logString:string="")
		local result:string = FindValue(node, fieldName, string(defaultValue), logString)
		if result = null then return defaultValue
		return int( result )
	End Function


	Function FindValueFloat:float(node:TxmlNode, fieldName:string, defaultValue:int, logString:string="")
		local result:string = FindValue(node, fieldName, string(defaultValue), logString)
		if result = null then return defaultValue
		return float( result )
	End Function


	Function FindValueBool:float(node:TxmlNode, fieldName:string, defaultValue:int, logString:string="")
		local result:string = FindValue(node, fieldName, string(defaultValue), logString)
		Select result.toLower()
			case "0", "false"	return false
			case "1", "true"	return true
		End Select
		return defaultValue
	End Function
End Type