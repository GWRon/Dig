SuperStrict
Framework Brl.StandardIO
Import "../../external/reflectionExtended/reflection.bmx"
'Import Brl.Reflection 'the modded one!

Type TMyType
	Field B:Int[0]
	Global C:int = 3
End Type
global my:TMyType = new TMyType

print "Definition: TMyType.B type="+TTypeID.ForObject(my).FindField("B").TypeID().name()
print "Content:            B type="+TTypeID.ForObject(my.B).name()

local a:string
print "Content:            a type="+TTypeID.ForObject(a).name()
'TTypeID.ForObject(a).Set(a, "HI")
'print "Content:            a type="+TTypeID.ForObject(a).name()
