SuperStrict
Framework Brl.StandardIO
?bmxng
'ng already handles that stuff
Import Brl.Reflection
?Not bmxng
Import "../../external/reflectionExtended/reflection.bmx"
?


Type TMyType
	Field B:Int[0]
	Global C:Int = 3
End Type
Global my:TMyType = New TMyType

Print "Definition: TMyType.B type="+TTypeId.ForObject(my).FindField("B").TypeID().name()
Print "Content:            B type="+TTypeId.ForObject(my.B).name()

Local a:String
Print "Content:            a type="+TTypeId.ForObject(a).name()
'TTypeID.ForObject(a).Set(a, "HI")
'print "Content:            a type="+TTypeID.ForObject(a).name()
