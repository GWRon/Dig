SuperStrict
Import brl.Reflection


'collection of useful functions
Type THelper
	'check whether a checkedObject equals to a limitObject
	'1) is the same object
	'2) is of the same type
	'3) is extended from same type
	Function ObjectsAreEqual:int(checkedObject:object, limit:object)
		'one of both is empty
		if not checkedObject then return FALSE
		if not limit then return FALSE
		'same object
		if checkedObject = limit then return TRUE
		'check if classname / type is the same (type-name given as limit )
		if string(limit)<>null
			local typeId:TTypeId = TTypeId.ForName(string(limit))
			'if we haven't got a valid classname
			if not typeId then return FALSE
			'if checked object is same type or does extend from that type
			if TTypeId.ForObject(checkedObject).ExtendsType(typeId) then return TRUE
		endif

		return FALSE
	End Function
End Type