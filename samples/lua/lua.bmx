SuperStrict

Import "../../base.util.luaengine.bmx"

Type TMyObject {_exposeToLua}
	Field prop:int = 10 {_exposeToLua="rw"} 'rw: make it changeable from lua
	'arrays can only get read with our implementation
	Field arr:int[] = [1,2,3] {_exposeToLua="rw"}
	Field myList:TList = CreateList() {_exposeToLua="rw"}

	Method Test:int(arg:string)
		print "TMyObject.test() invoked: " +arg
	End Method

	Method GetList:TList()
		local list:TList = CreateList()
		list.AddLast("1")
		list.AddLast("2")
		list.AddLast("3")
		return list
	End Method
End Type


'directly exposed functions (with no own "table")
'have to be in a specific form:
'- luaState as param
'- "real param" handling within the function
Function LuaPrint:int(luaState:Byte Ptr)
	'number of arguments
	local argCount:int = lua_gettop(luaState)
	local text:string = ""
	'from last to first
	for local i:int = 0 to argCount
		if not lua_isnil(luaState,-1 )
			text = String.FromCString(lua_tostring(luaState, -1)) + text
			'pop the string
			lua_pop(luaState, 1)
		endif
	Next
	print "LUA print: " +text
End Function



Global MyObject:TMyObject = new TMyObject

For local i:int = 0 to 0
	print "Lua instance: "+i
	local luaEngine:TLuaEngine = TLuaEngine.Create(LoadText("test.lua"))

	luaEngine.RegisterBlitzmaxObject("MyObject", MyObject)
	luaEngine.RegisterFunction("myprint", LuaPrint)


	print "calling luafile's ~qMyRun()~q'"
	luaEngine.CallLuaFunction("MyRun")
	print "prop is now: " +MyObject.prop
	print "arr2 is now: " +MyObject.arr[2] +" = 30 ?"
	if MyObject.myList then print "list exists"
	if not MyObject.myList then print "list exists no more"
	print "---"
Next