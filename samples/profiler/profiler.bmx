SuperStrict

Import "../../base.util.profiler.bmx"


For local i:int = 0 to 30
	TProfiler.Enter("Test")
		TProfiler.Enter("Test1")
			TProfiler.Enter("Test2")
				delay(1)
			TProfiler.Leave("Test2")
		TProfiler.Leave("Test1")

		'call from different depth
		TProfiler.Enter("Test2")
			delay(1)
		TProfiler.Leave("Test2")
	TProfiler.Leave("Test")
Next

print TProfiler.GetLog()
TProfiler.DumpLog("log.profiler.txt")