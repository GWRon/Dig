SuperStrict
Framework Brl.StandardIO
Import "../../base.util.directorytree.bmx"

'SAMPLE: all files
local dirTree:TDirectoryTree = new TDirectoryTree.SimpleInit()
dirTree.relativePaths = False 'use absolute paths
dirTree.ScanDir() 'just scan CWD

print "ALL FILES (absolute path):"
For local f:string = EachIn dirTree.GetFiles()
	print "|- "+f
Next



'SAMPLE: all but .bmxfiles
dirTree.Init("", ["*"], ["bmx"], ["*"] )
dirTree.relativePaths = True
dirTree.ScanDir() 'just scan CWD

print "ALL BUT .bmx FILES:"
For local f:string = EachIn dirTree.GetFiles()
	print "|- "+f
Next



'SAMPLE: all but .o (other variant to exclude) 
dirTree.SimpleInit()
dirTree.SetExcludeFileEndings(["o"])
dirTree.relativePaths = True
dirTree.ScanDir() 'just scan CWD

print "ALL BUT .o FILES:"
For local f:string = EachIn dirTree.GetFiles()
	print "|- "+f
Next



'SAMPLE: scan all in .bmx-directory (created after compilaton)
dirTree.SimpleInit()
dirTree.relativePaths = False
dirTree.ScanDir(".bmx") 'scan .bmx-directory (hidden on linux/mac)
print "ALL FILES (in .bmx-dir):"
For local f:string = EachIn dirTree.GetFiles()
	print "|- "+f
Next



'SAMPLE: find all files containing "directorytree.bmx" in URI
dirTree.SimpleInit()
dirTree.relativePaths = False
dirTree.ScanDir("") 'scan CWD
print "ALL FILES (containing ~qdirectorytree.bmx~q somewhere in URI):"
For local f:string = EachIn dirTree.GetFiles("", "","","directorytree.bmx")
	print "|- "+f
Next
print "-----"