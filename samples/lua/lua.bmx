SuperStrict
Framework BRL.StandardIO
Import "../../base.util.luaengine.bmx"

Type TMyObject {_exposeToLua}
	Field prop:Int = 10 {_exposeToLua="rw"} 'rw: make it changeable from lua
	'arrays can only get read with our implementation
	Field arr:Int[] = [1,2,3] {_exposeToLua="rw"}
	Field myList:TList = CreateList() {_exposeToLua="rw"}

	Method Test:Int(arg:String)
		Print "TMyObject.test() invoked: " +arg
	End Method

	Method GetList:TList()
		Local list:TList = CreateList()
		list.AddLast("1")
		list.AddLast("2")
		list.AddLast("3")
		Return list
	End Method
End Type


'directly exposed functions (with no own "table")
'have to be in a specific form:
'- luaState as param
'- "real param" handling within the function
Function LuaPrint:Int(luaState:Byte Ptr)
	'number of arguments
	Local argCount:Int = lua_gettop(luaState)
	Local text:String = ""
	'from last to first
	For Local i:Int = 0 Until argCount
		If Not lua_isnil(luaState,-1 )
			text = String.FromCString(lua_tostring(luaState, -1)) + text
			'pop the string
			lua_pop(luaState, 1)
		EndIf
	Next
	Print "LUA print: " +text
End Function



Global MyObject:TMyObject = New TMyObject

For Local i:Int = 0 To 0
	Print "Lua instance: "+i
	Local luaEngine:TLuaEngine = TLuaEngine.Create(LoadText("test.lua"))

	luaEngine.RegisterBlitzmaxObject("MyObject", MyObject)
	luaEngine.RegisterFunction("myprint", LuaPrint)


	Print "calling luafile's ~qMyRun()~q'"
	Print ">>>>>>"
	luaEngine.CallLuaFunction("MyRun")
	Print "<<<<<<"
	Print "prop is now: " +MyObject.prop
	Print "arr2 is now: " +MyObject.arr[0]+","+MyObject.arr[1]+","+MyObject.arr[2]+" (was 1,2,3)"
	If MyObject.myList 
		Print "list exists"
	Else
		Print "list exists no longer"
	EndIf
	Print "---"
Next