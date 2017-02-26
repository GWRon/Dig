SuperStrict

Framework Brl.StandardIO
Import "../../base.util.mersenne.bmx"

SeedRand(10)
print "Rand(  0, 10)= "+RandRange(0,10)  +"   =10 ?"
print "Rand(-10,  0)= "+RandRange(-10,0) +"   =-9 ?"
print "Rand(  0,  0)=  "+RandRange(0,0)  +"   = 0 ?"
print "Rand(  0,-10)= "+RandRange(0,-10)  +"   =-8 ?"
