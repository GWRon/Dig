SuperStrict
Framework Brl.StandardIO
Import "../../base.util.math.bmx"


'0.95 is internally "0.94999999"
print MathHelper.NumberToString(0.95, 2) +" = 0.95"

print MathHelper.NumberToString(0.95, 3) +" = 0.950"

print MathHelper.NumberToString(-0.95, 2) +" = -0.95"

print MathHelper.NumberToString(1.00, 3) +" = 1.000"
print MathHelper.NumberToString(1.01, 3) +" = 1.010"
print MathHelper.NumberToString(1.019, 2) +" = 1.02"
print MathHelper.NumberToString(1.019, 1) +" = 1.0"
print MathHelper.NumberToString(0, 2) +" = 0.00"
print MathHelper.NumberToString(0, 1) +" = 0.0"
print MathHelper.NumberToString(0, 0) +" = 0"

print MathHelper.NumberToString(-1.123456789, 5) +" = -1.12346"
print MathHelper.NumberToString(-1.123456789, 0) +" = -1"


print MathHelper.NumberToString(-1.000001, 2, True) +" = -1"


print MathHelper.NumberToString(92190, 3, True) +" = 92190"
print MathHelper.NumberToString(92019, 3, True) +" = 92019"


print dottedValue(92190)
print dottedValue(92019)

print convertValue(92190, 2)
print convertValue(92019, 2)


	Function convertValue:String(value:Float, digitsAfterDecimalPoint:Int=2, typ:Int=0, delimeter:String=",")
		typ = MathHelper.Clamp(typ, 0,3)
      ' typ 1: 250000 = 250Tsd
      ' typ 2: 250000 = 0,25Mio
      ' typ 3: 250000 = 0,0Mrd
      ' typ 0: 250000 = 0,25Mio (automatically)

		'find out amount of digits before decimal point
		Local intValue:Int = Int(value)
		Local length:Int = String(intValue).length
		'avoid problems with "0.000" being shown as "-21213234923"
		If value = 0 Then intValue = 0;length = 1
		'do not count negative signs.
		If intValue < 0 Then length:-1

		'automatically
		If typ=0
			If length < 10 And length >= 7 Then typ=2
			If length >= 10 Then typ=3
		EndIf
		'250000 = 250Tsd -> divide by 1000
		If typ=1 Then Return MathHelper.NumberToString(value/1000.0, 0)+" "+"ABBREVIATION_THOUSAND"
		'250000 = 0,25Mio -> divide by 1000000
		If typ=2 Then Return MathHelper.NumberToString(value/1000000.0, 2)+" "+"ABBREVIATION_MILLION"
		'250000 = 0,0Mrd -> divide by 1000000000
		If typ=3 Then Return MathHelper.NumberToString(value/1000000000.0, 2)+" "+"ABBREVIATION_BILLION"

		return dottedValue(value)
    End Function

	Function dottedValue:String(value:Double, thousandsDelimiter:String=".", decimalDelimiter:String=",")
		'is there a "minus" in front ?
		Local addSign:String = ""
		If value < 0 Then addSign="-"

		Local stringValue:String = String(Abs(value))
		'find out amount of digits before decimal point
		Local length:Int = String(Abs(Long(value))).length
		'add 2 to length, as this contains the "." delimiter
		Local fractionalValue:String = Mid(stringValue, length+2, -1)
		Local decimalValue:String = Left(stringValue, length)
		Local result:String = ""

		'do we have a fractionalValue <> ".000" ?
		If Long(fractionalValue) > 0 Then result :+ decimalDelimiter + fractionalValue
	
		For Local i:Int = decimalValue.length-1 To 0 Step -1
			result = Chr(decimalValue[i]) + result

			'every 3rd char, but not if the last one (avoid 100 -> .100)
			If (decimalValue.length-i) Mod 3 = 0 And i > 0 
				result = thousandsDelimiter + result 
			EndIf
		Next
		Return addSign+result
	End Function