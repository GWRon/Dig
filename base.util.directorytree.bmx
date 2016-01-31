Rem
	===========================================================
	DIRECTORY SCANNING CLASS
	===========================================================

	This code allows scanning and storing the content of a given
	directory.

ENDREM
SuperStrict
Import BRL.Map
Import BRL.LinkedList
Import BRL.FileSystem


Type TDirectoryTree
	Field directories:TList             = CreateList()
	Field filePaths:TList               = CreateList()
	'root path of the scanned directory
	Field baseDirectory:String         = ""
	'files to include/exclude in the tree. "*" means all
	Field _includeFileEndings:TList    = CreateList()
	Field _excludeFileEndings:TList    = CreateList()
	Field _includeFileNames:TList      = CreateList()
	Field _excludeFileNames:TList      = CreateList()
	Field _includeDirectoryNames:TList = CreateList()
	Field _excludeDirectoryNames:TList = CreateList()
	Field relativePaths:int = True


	Method New()
		baseDirectory = AppDir
	End Method

	Method SimpleInit:TDirectoryTree( baseDirectory:String="" )
		return Init(baseDirectory, ["*"], null, ["*"], null)
	End Method
	

	'initialize object
	Method Init:TDirectoryTree( baseDirectory:String="", includeFileEndings:String[] = Null, excludeFileEndings:String[] = Null, includeDirectoryNames:String[] = Null, excludeDirectoryNames:String[] = Null )
		_includeFileEndings.Clear()
		_excludeFileEndings.Clear()
		_includeFileNames.Clear()
		_excludeFileNames.Clear()
		_includeDirectoryNames.Clear()
		_excludeDirectoryNames.Clear()
		directories.Clear()
		filePaths.Clear()
	
		'include all if not defined differently
		If includeFileEndings Then AddIncludeFileEndings(includeFileEndings)
		If includeDirectoryNames Then AddIncludeDirectoryNames(includeDirectoryNames)
'		AddIncludeFileNames(["*"])
		
		'exclude none if nothing was given
		If excludeFileEndings Then AddExcludeFileEndings(excludeFileEndings)
		If excludeDirectoryNames Then AddExcludeDirectoryNames(excludeDirectoryNames)

		Self.baseDirectory = baseDirectory
		If Self.baseDirectory = "" then Self.baseDirectory = AppDir 

		Return Self
	End Method


	Method AddFile(fileURI:String, addAtTop:int=False)
		If filePaths.Contains(fileURI) Then Return
		if addAtTop
			filePaths.AddFirst(fileURI)
		else
			filePaths.AddLast(fileURI)
		endif
	End Method


	Method AddDirectory(directoryURI:String, addAtTop:int=False)
		If directories.Contains(directoryURI) Then Return
		if addAtTop
			directories.AddFirst(directoryURI)
		else
			directories.AddLast(directoryURI)
		endif
	End Method


	'add a file ending to the list of allowed file endings
	Method AddIncludeFileEndings( endings:String[], resetFirst:Int = False )
		If resetFirst Then _includeFileEndings.Clear()

		For Local ending:String = EachIn endings
			_includeFileEndings.AddLast(ending.toLower())
		Next
	End Method


	'add a file ending to the list of forbidden file endings
	Method AddExcludeFileEndings( endings:String[], resetFirst:Int = False )
		If resetFirst Then _excludeFileEndings.Clear()

		For Local ending:String = EachIn endings
			_excludeFileEndings.AddLast(ending.toLower())
		Next
	End Method


	'add a file name to the list of allowed file name
	Method AddIncludeFileNames( names:String[], resetFirst:Int = False )
		If resetFirst Then _includeFileNames.Clear()

		For Local name:String = EachIn names
			_includeFileNames.AddLast(name.toLower())
		Next
	End Method


	'add a file name to the list of forbidden file names
	Method AddExcludeFileNames( names:String[], resetFirst:Int = False )
		If resetFirst Then _excludeFileNames.Clear()

		For Local name:String = EachIn names
			_excludeFileNames.AddLast(name.toLower())
		Next
	End Method
	

	'add a directory name to the list of allowed directories
	Method AddIncludeDirectoryNames( dirNames:String[], resetFirst:Int = False )
		If resetFirst Then _includeDirectoryNames.Clear()

		For Local dirName:String = EachIn dirNames
			_includeDirectoryNames.AddLast(dirName.toLower())
		Next
	End Method


	'add a directory to the list of forbidden directories
	Method AddExcludeDirectoryNames( dirNames:String[], resetFirst:Int = False )
		If resetFirst Then _excludeDirectoryNames.Clear()

		For Local dirName:String = EachIn dirNames
			_excludeDirectoryNames.AddLast(dirName.toLower())
		Next
	End Method


	Method GetURI:string(uri:string)
		if relativePaths then return uri.Replace(baseDirectory+"/","")
		return uri
	End Method
	

	'scans all files and directories within the given base
	'directory.
	'if no file ending is added until scanning, all files
	'will get added
	Method ScanDir:Int( directory:String="", sortResults:int = True )
		If directory = "" Then directory = baseDirectory
		?bmxng
		Local dirHandle:Byte Ptr = ReadDir(directory)
		?not bmxng
		Local dirHandle:Int = ReadDir(directory)
		?
		If Not dirHandle Then Return False


		Local file:String
		Local uri:String
		Repeat
			file = NextFile(dirHandle)
			If file = "" Then Exit
			'skip chgDir-entries
			If file = ".." Or file = "." Then Continue

			uri = directory + "/" + file

			Select FileType(uri)
				Case 1
					'skip forbidden file endings
					If _excludeFileEndings.Contains( ExtractExt(file).toLower() ) Then Continue
					'skip files with non-enabled file endings
					If _includeFileEndings.Count() > 0 and Not _includeFileEndings.Contains( ExtractExt(file).toLower() ) And Not _includeFileEndings.Contains("*") Then Continue

					'skip forbidden file names
					If _excludeFileNames.Contains( StripAll(file).toLower() ) Then Continue
					'skip files with non-enabled file names
					If _includeFileNames.Count() > 0 and Not _includeFileNames.Contains( StripAll(file).toLower() ) And Not _includeFileNames.Contains("*") Then Continue

					AddFile( GetURI(uri) )
				Case 2
					'skip forbidden directories
					If _excludeDirectoryNames.Contains( file.toLower() ) Then Continue
					'skip directories with non-enabled directory names
					If Not _includeDirectoryNames.Contains( file.toLower() ) And Not _includeDirectoryNames.Contains("*") Then Continue

					AddDirectory( GetURI(uri) )
					ScanDir(uri)
			End Select
		Forever
		
		CloseDir(dirHandle)

		if sortResults
			directories.Sort(True)
			filePaths.Sort(True)
		endif
		
		Return True
	End Method


	'returns all found files for a given filter
	Method GetFiles:String[](fileName:String="", fileEnding:String="", URIstartsWith:String="")
		Local result:String[]
		For Local uri:String = EachIn filePaths
			uri = GetURI(uri) 'strip absolute path if necessary
			'skip files with wrong filename - case sensitive
			If fileName <> "" And StripDir(uri) <> fileName Then Continue
			'skip uris not starting with given filter
			If URIstartsWith <> "" And Not uri.StartsWith(URIstartsWith) Then Continue
			'skip uris having the wrong file ending - case INsensitive
			If fileEnding <> "" And ExtractExt(uri).toLower() <> fileEnding.toLower() Then Continue

			result :+ [uri]
		Next
		Return result
	End Method
End Type