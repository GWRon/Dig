SuperStrict

Framework Brl.StandardIO
Import Brl.PNGLoader
Import Brl.JPGLoader
Import "../../base.gfx.imagehelper.bmx"
Import "../../base.util.directorytree.bmx"


'=== prepare app arguments ===
local bleedingBorder:int = 0
local inputDir:string = ""
local outputDir:string = "trimmed"
if AppArgs.length > 1 then inputDir = AppArgs[1]
if inputDir <> "" then outputDir = inputDir+"/"+outputDir

'=== read files to process ===
'load jpg, jpeg, png and skip directory "trimmed"
local dirTree:TDirectoryTree = new TDirectoryTree.Init("", ["jpg", "jpeg", "png"], null, null, ["trimmed"])
dirTree.ScanDir(inputDir)


'=== process files ===
print "Input dir: ~q"+inputDir+"~q"
local files:string[] = dirTree.GetFiles()
if files.length = 0
	print "- No files to process."
	end
endif

print "Output dir: ~q"+outputDir+"~q"
'create trimmed dir if not existing
if FileMode(outputDir) = -1
	print "- Creating dir: ~q"+outputDir+"~q."
	CreateDir(outputDir)
	if FileMode(outputDir) = -1 then Throw "Failed to create output directory."
endif

print "Processing ["+files.length+" files]"
For local imageFile:string = EachIn files
	local outputURI:string = outputDir + "/" + imageFile.Replace(inputDir+"/", "")

	print "- processing: ~q"+imageFile+"~q"

	local img:TImage = LoadImage(imageFile)
	if not img
		print "  - failed to load image"
		continue
	endif
	
	local offset:TRectangle = new TRectangle
	'check alpha = 0, set color=null to autotrim the color at 0,0 in the
	'image 
	local trimColor:TColor = new TColor.Create(-1,-1,-1, 0)
	local newImg:Timage = TrimImage(img, offset, trimColor, bleedingBorder)
	print "  - trimmed: "+img.width+","+img.height+" -> "+ newImg.width+","+newImg.height+" (offset: "+int(offset.GetLeft())+","+int(offset.GetTop()) +" / " + int(offset.GetRight())+","+int(offset.GetBottom())+")"

	if SavePixmapPNG(LockImage(newImg), outputURI)
		print "  - saved as ~q"+outputURI+"~q."
	else 
		print "  - failed to save as ~q"+outputURI+"~q."
	endif
Next