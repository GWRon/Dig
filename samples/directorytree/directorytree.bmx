SuperStrict
Framework Brl.StandardIO
Import "../../base.util.directorytree.bmx"

'SAMPLE: all files
local dirTree:TDirectoryTree = new TDirectoryTree.SimpleInit()
dirTree.relativePaths = False 'use absolute paths
dirTree.ScanDir() 'just scan CWD

print "ALL FILES:"
For local f:string = EachIn dirTree.GetFiles()
	print f
Next
print "-----"



'SAMPLE: all but .bmxfiles
dirTree.Init("", ["*"], ["bmx"], ["*"] )
dirTree.relativePaths = True
dirTree.ScanDir() 'just scan CWD

print "ALL BUT .bmx FILES:"
For local f:string = EachIn dirTree.GetFiles()
	print f
Next
print "-----"



'SAMPLE: all but .o (other variant to exclude) 
dirTree.SimpleInit()
dirTree.AddExcludeFileEndings(["o"])
dirTree.relativePaths = True
dirTree.ScanDir() 'just scan CWD

print "ALL BUT .bmx FILES:"
For local f:string = EachIn dirTree.GetFiles()
	print f
Next
print "-----"