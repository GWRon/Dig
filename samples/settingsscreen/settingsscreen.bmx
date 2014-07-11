SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.framework.graphicalapp.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.util.registry.imageloader.bmx"
Import "../../base.gfx.bitmapfont.bmx"
Import "../../base.util.registry.bitmapfontloader.bmx"

Import "../../base.gfx.sprite.bmx"
Import "../../base.framework.screen.bmx"
Import "../../base.util.registry.bmx"
Import "../../base.gfx.gui.button.bmx"
Import "../../base.gfx.gui.backgroundbox.bmx"
Import "../../base.gfx.gui.checkbox.bmx"
Import "../../base.gfx.gui.input.bmx"
Import "../../base.gfx.gui.dropdown.bmx"
Import "../../base.gfx.gui.window.modal.bmx"

Import "../../base.util.data.xmlstorage.bmx"
Import "app.screen.bmx"




Global MyApp:TMyApp = new TMyApp
MyApp.debugLevel = 1

Type TMyApp extends TGraphicalApp
	Field mouseCursorState:int = 0
	'developer/base configuration
	Field configBase:TData = new TData
	'configuration containing base + user
	Field config:TData = new TData


	Method Prepare:int()
		super.Prepare()

		local gm:TGraphicsManager = TGraphicsManager.GetInstance()
		'scale everything from 800x600 to 1024x768
	'	gm.SetResolution(1024, 768)
	'	gm.SetDesignedResolution(800, 600)
	'	gm.InitGraphics()

		'we use a full screen background - so no cls needed
		autoCls = False

		'=== LOAD RESOURCES ===
		local registryLoader:TRegistryLoader = new TRegistryLoader
		'if loading from a "parent directory" - state this here
		'-> all resources can get loaded with "relative paths"
		'registryLoader.baseURI = "../"

		'afterwards we can display background images and cursors
		'"TRUE" indicates that the content has to get loaded immediately
		registryLoader.LoadFromXML("res/config/startup.xml", TRUE)
		registryLoader.LoadFromXML("res/config/resources.xml")

		'set a basic font ?
		'SetImageFont(LoadImageFont("../res/fonts/Vera.ttf", 12))

		'=== CREATE DEMO SCREENS ===
		GetScreenManager().Set(new TSettingsScreen.Init("main"))
		GetScreenManager().SetCurrent( GetScreenManager().Get("main") )
	End Method


	Method Update:Int()
		'fetch and cache mouse and keyboard states for this cycle
		GUIManager.StartUpdates()

		'=== UPDATE GUI ===
		'system wide gui elements
		GuiManager.Update("SYSTEM")

		'run parental update (screen handling)
		Super.Update()

		'check if new resources have to get loaded
		TRegistryUnloadedResourceCollection.GetInstance().Update()

		'reset modal window states
		GUIManager.EndUpdates()
	End Method


	Method RenderContent:Int()
		'=== RENDER GUI ===
		'system wide gui elements
		GuiManager.Draw("SYSTEM")
	End Method


	Method RenderLoadingResourcesInformation:Int()
		'do nothing if there is nothing to load
		if TRegistryUnloadedResourceCollection.GetInstance().FinishedLoading() then return TRUE

		'reduce instance requests
		local RURC:TRegistryUnloadedResourceCollection = TRegistryUnloadedResourceCollection.GetInstance()


		SetAlpha 0.2
		SetColor 50,0,0
		DrawRect(0, GraphicsHeight() - 20, GraphicsWidth(), 20)
		SetAlpha 1.0
		SetColor 255,255,255
		DrawText("Loading: "+RURC.loadedCount+"/"+RURC.toLoadCount+"  "+String(RURC.loadedLog.Last()), 0, 580)
	End Method


	Method RenderHUD:Int()
		'=== DRAW RESOURCEL LOADING INFORMATION ===
		'if there is a resource loading currently - display information
		RenderLoadingResourcesInformation()

		'=== DRAW MOUSE CURSOR ===
		GetSpriteFromRegistry("gfx_mousecursor"+mouseCursorState).Draw(MouseManager.x, MouseManager.y, 0)
	End Method
End Type



Type TGUISpriteDropDown extends TGUIDropDown

	Method Create:TGUISpriteDropDown(position:TVec2D = null, dimension:TVec2D = null, value:string="", maxLength:Int=128, limitState:String = "")
		Super.Create(position, dimension, value, maxLength, limitState)
		Return self
	End Method
	

	'override to add sprite next to value
	Method DrawContent:Int(position:TVec2D)
		'position is already a copy, so we can reuse it without
		'copying it first

		'draw sprite
		if TGUISpriteDropDownItem(selectedEntry)
			local scaleSprite:float = 0.8
			local labelHeight:int = GetFont().GetHeight(GetValue())
			local item:TGUISpriteDropDownItem = TGUISpriteDropDownItem(selectedEntry)
			local sprite:TSprite = GetSpriteFromRegistry( item.data.GetString("spriteName", "default") )
			if item and sprite.GetName() <> "defaultSprite"
				local displaceY:int = -1 + 0.5 * (labelHeight - (item.GetSpriteDimension().y * scaleSprite))
				sprite.DrawArea(position.x, position.y + displaceY, item.GetSpriteDimension().x * scaleSprite, item.GetSpriteDimension().y * scaleSprite)
				position.AddXY(item.GetSpriteDimension().x * scaleSprite + 3, 0)
			endif
		endif

		'draw value
		Super.DrawContent(position)
	End Method
End Type


Type TGUISpriteDropDownItem Extends TGUIDropDownItem
	Global spriteDimension:TVec2D
	Global defaultSpriteDimension:TVec2D = new TVec2D.Init(24, 24)
	

    Method Create:TGUISpriteDropDownItem(position:TVec2D=null, dimension:TVec2D=null, value:String="")
		if not dimension
			dimension = new TVec2D.Init(-1, GetSpriteDimension().y + 2)
		else
			dimension.x = Max(dimension.x, GetSpriteDimension().x)
			dimension.y = Max(dimension.y, GetSpriteDimension().y)
		endif
		Super.Create(position, dimension, value)
		return self
    End Method


    Method GetSpriteDimension:TVec2D()
		if not spriteDimension then return defaultSpriteDimension
		return spriteDimension
    End Method


	Method SetSpriteDimension:int(dimension:TVec2D)
		spriteDimension = dimension.copy()

		Resize(..
			Max(dimension.x, GetSpriteDimension().x), ..
			Max(dimension.y, GetSpriteDimension().y) ..
		)
	End Method
    

	Method DrawValue:int()
		local valueX:int = getScreenX()

		local sprite:TSprite = GetSpriteFromRegistry( data.GetString("spriteName", "default") )
		if sprite.GetName() <> "defaultSprite"
			sprite.DrawArea(valueX, GetScreenY()+1, GetSpriteDimension().x, GetSpriteDimension().y)
			valueX :+ GetSpriteDimension().x + 3
		else
			valueX :+ GetSpriteDimension().x + 3
		endif
		'draw value
		GetFont().draw(value, valueX, Int(GetScreenY() + 2 + 0.5*(rect.getH()- GetFont().getHeight(value))), valueColor)
	End Method
End Type



Type TSettingsWindow
	Field modalDialogue:TGUIModalWindow
	Field inputPlayerName:TGUIInput
	Field inputChannelName:TGUIInput
	Field inputStartYear:TGUIInput
	Field inputStationmap:TGUIDropDown
	Field inputDatabase:TGUIDropDown
	Field checkMusic:TGUICheckbox
	Field checkSfx:TGUICheckbox
	Field dropdownRenderer:TGUIDropDown
	Field checkFullscreen:TGUICheckbox
	Field inputGameName:TGUIInput
	Field inputOnlinePort:TGUIInput


	Method ReadGuiValues:TData()
		local data:TData = new TData

		data.Add("playername", inputPlayerName.GetValue())
		data.Add("channelname", inputChannelName.GetValue())
		data.Add("startyear", inputStartYear.GetValue())
		'data.Add("stationmap", inputStationmap.GetValue())
		'data.Add("database", inputDatabase.GetValue())
		data.AddBoolString("sound_music", checkMusic.IsChecked())
		data.AddBoolString("sound_effects", checkSfx.IsChecked())

		data.AddBoolString("fullscreen", checkFullscreen.IsChecked())

		data.Add("gamename", inputGameName.GetValue())
		data.Add("onlineport", inputOnlinePort.GetValue())

		return data
	End Method


	Method SetGuiValues:int(data:TData)
		inputPlayerName.SetValue(data.GetString("playername", "Player"))
		inputChannelName.SetValue(data.GetString("channelname", "My Channel"))
		inputStartYear.SetValue(data.GetInt("startyear", 1985))
		'inputStationmap.SetValue(data.GetString("stationmap", "config/maps/germany.xml"))
		'inputDatabase.SetValue(data.GetString("database", "res/database.xml"))
		checkMusic.SetChecked(data.GetBool("sound_music", True))
		checkSfx.SetChecked(data.GetBool("sound_effects", True))

		checkFullscreen.SetChecked(data.GetBool("fullscreen", True))

		inputGameName.SetValue(data.GetString("gamename", "New Game"))
		inputOnlinePort.SetValue(data.GetInt("onlineport", 4544))
	End Method


	Method Init:TSettingsWindow()
		'LAYOUT CONFIG
		local nextY:int = 0, nextX:int = 0
		local rowWidth:int = 215
		local checkboxWidth:int = 180
		local inputWidth:int = 170
		local labelH:int = 12
		local inputH:int = 0
		local windowW:int = 670
		local windowH:int = 380

		modalDialogue = new TGUIModalWindow.Create(new TVec2D, new TVec2D.Init(windowW, windowH), "SYSTEM")

		modalDialogue.SetDialogueType(2)
		modalDialogue.buttons[0].SetCaption(GetLocale("SAVE_AND_APPLY"))
		modalDialogue.buttons[0].Resize(160,-1)
		modalDialogue.buttons[1].SetCaption(GetLocale("CANCEL"))
		modalDialogue.buttons[1].Resize(160,-1)
		'as content area starts to late for automatic caption positioning
		'we set a specific area to use
		modalDialogue.SetCaptionArea(new TRectangle.Init(-1,5,-1,25))
		modalDialogue.SetCaptionAndValue("Settings", "")

		local canvas:TGUIObject = modalDialogue.GetGuiContent()
				
		local labelTitleGameDefaults:TGUILabel = New TGUILabel.Create(new TVec2D.Init(0, nextY), "Vorgaben ~qNeues Spiel~q")
		labelTitleGameDefaults.SetFont(GetBitmapFont("default", 11, BOLDFONT))
		canvas.AddChild(labelTitleGameDefaults)
		nextY :+ 25

		local labelPlayerName:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Spielername:")
		inputPlayerName = New TGUIInput.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(inputWidth,-1), "", 128)
		canvas.AddChild(labelPlayerName)
		canvas.AddChild(inputPlayerName)
		inputH = inputPlayerName.GetScreenHeight()
		nextY :+ inputH + labelH * 1.5

		local labelChannelName:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Sendername:")
		inputChannelName = New TGUIInput.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(inputWidth,-1), "", 128)
		canvas.AddChild(labelChannelName)
		canvas.AddChild(inputChannelName)
		nextY :+ inputH + labelH * 1.5

		local labelStartYear:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Startjahr:")
		inputStartYear = New TGUIInput.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(50,-1), "", 4)
		canvas.AddChild(labelStartYear)
		canvas.AddChild(inputStartYear)
		nextY :+ inputH + labelH * 1.5

		local labelStationmap:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Ausstrahlungsland:")
		inputStationmap = New TGUIDropDown.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(inputWidth,-1), "germany.xml", 128)
		inputStationmap.disable()
		canvas.AddChild(labelStationmap)
		canvas.AddChild(inputStationmap)
		nextY :+ inputH + labelH * 1.5

		local labelDatabase:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Datenbank:")
		inputDatabase = New TGUIDropDown.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(inputWidth,-1), "database.xml", 128)
		inputDatabase.disable()
		canvas.AddChild(labelDatabase)
		canvas.AddChild(inputDatabase)
		nextY :+ inputH + labelH * 1.5


		nextY = 0
		nextX = 1*rowWidth
		'SOUND
		local labelTitleSound:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Soundausgabe")
		labelTitleSound.SetFont(GetBitmapFont("default", 11, BOLDFONT))
		canvas.AddChild(labelTitleSound)
		nextY :+ 25

		checkMusic = New TGUICheckbox.Create(new TVec2D.Init(nextX, nextY), new TVec2D.Init(checkboxWidth,-1), "")
		checkMusic.SetCaptionValues("An, Musik wird abgespielt.", "Aus, es wird keine Musik abgespielt." )
		canvas.AddChild(checkMusic)
		nextY :+ Max(inputH, checkMusic.GetScreenHeight())

		checkSfx = New TGUICheckbox.Create(new TVec2D.Init(nextX, nextY), new TVec2D.Init(checkboxWidth,-1), "")
		checkSfx.SetCaptionValues("An, Soundeffekte werden abgespielt.", "Aus, es werden keine Soundeffekte abgespielt." )
		canvas.AddChild(checkSfx)
		nextY :+ Max(inputH, checkSfx.GetScreenHeight())
		nextY :+ 15


		'GRAPHICS
		local labelTitleGraphics:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Grafik")
		labelTitleGraphics.SetFont(GetBitmapFont("default", 11, BOLDFONT))
		canvas.AddChild(labelTitleGraphics)
		nextY :+ 25

		local labelRenderer:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Renderer:")
		dropdownRenderer = New TGUIDropDown.Create(new TVec2D.Init(nextX, nextY + 12), new TVec2D.Init(inputWidth,-1), "Automatisch", 128)
		local rendererValues:string[] = ["0", "3"]
		local rendererTexts:string[] = ["OpenGL", "Buffered OpenGL"]
		?Win32
			renderValues :+ ["1","2]
			rendererTexts : + ["DirectX 7", "DirectX 9"]
		?
		local itemHeight:int = 0
		For local i:int = 0 until rendererValues.Length
			local item:TGUIDropDownItem = new TGUIDropDownItem.Create(null, null, rendererTexts[i])
			item.SetValueColor(TColor.CreateGrey(50))
			item.data.Add("value", rendererValues[i])
			dropdownRenderer.AddItem(item)
			if itemHeight = 0 then itemHeight = item.GetScreenHeight()
		Next
		dropdownRenderer.SetListContentHeight(itemHeight * Len(rendererValues))

		canvas.AddChild(labelRenderer)
		canvas.AddChild(dropdownRenderer)
'		GuiManager.SortLists()
		nextY :+ inputH + labelH * 1.5

		checkFullscreen = New TGUICheckbox.Create(new TVec2D.Init(nextX, nextY), new TVec2D.Init(checkboxWidth,-1), "")
		checkFullscreen.SetCaptionValues("Vollbildmodus aktiviert", "Vollbildmodus deaktiviert" )
		canvas.AddChild(checkFullscreen)
		nextY :+ Max(inputH, checkFullscreen.GetScreenHeight()) + labelH * 1.5


		'MULTIPLAYER
		nextY = 0
		nextX = 2*rowWidth
		local labelTitleMultiplayer:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Mehrspieler")
		labelTitleMultiplayer.SetFont(GetBitmapFont("default", 11, BOLDFONT))
		canvas.AddChild(labelTitleMultiplayer)
		nextY :+ 25

		local labelGameName:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Spieltitel:")
		inputGameName = New TGUIInput.Create(new TVec2D.Init(nextX, nextY + labelH), new TVec2D.Init(inputWidth,-1), "", 128)
		canvas.AddChild(labelGameName)
		canvas.AddChild(inputGameName)
		nextY :+ inputH + labelH * 1.5

	
		local labelOnlinePort:TGUILabel = New TGUILabel.Create(new TVec2D.Init(nextX, nextY), "Port fuer Onlinespiele:")
		inputOnlinePort = New TGUIInput.Create(new TVec2D.Init(nextX, nextY + 12), new TVec2D.Init(50,-1), "", 4)
		canvas.AddChild(labelOnlinePort)
		canvas.AddChild(inputOnlinePort)
		nextY :+ inputH + 5

		'fill values
		SetGuiValues(MyApp.config)

		return self
	End Method
End Type


Type TSettingsScreen extends TScreen
	'store it so we can check for existence later on
	global settingsWindow:TSettingsWindow

	Method Setup:Int()
		local button:TGUIButton = new TGUIButton.Create(new TVec2D.Init(20,20), new TVec2D.Init(130,-1), "Open Settings", self.GetName())

		local dropdownLanguage:TGUISpriteDropDown = New TGUISpriteDropDown.Create(new TVec2D.Init(620, 560), new TVec2D.Init(170,-1), "Sprache", 128, self.GetName())
		local languageValue:string[] = ["de", "en", "it", "ru", "fr", "cz", "tr"]
		local languageText:string[] = ["Deutsch", "English", "Italiano", "Русский", "Français", "Čeština", "Türkçe"]
		local itemHeight:int = 0
		For local i:int = 0 until languageText.Length
			local item:TGUISpriteDropDownItem = new TGUISpriteDropDownItem.Create(null, null, languageText[i])
			item.SetValueColor(TColor.clBlack)
			item.data.Add("value", languageValue[i])
			item.data.add("spriteName", "flag_"+languageValue[i])
			dropdownLanguage.AddItem(item)
			if itemHeight = 0 then itemHeight = item.GetScreenHeight()
		Next
		GuiManager.SortLists()
		'we want to have 4 items visible at once
		dropdownLanguage.SetListContentHeight(itemHeight * 4)


		'a modal dialogue
		'handle clicking on the button
		EventManager.RegisterListenerFunction("guiobject.onclick", onClickCreateModalDialogue, button)
		'handle saving applying
		EventManager.RegisterListenerFunction("guiModalWindow.onClose", onCloseModalDialogue)
	End Method


	Function onCloseModalDialogue:Int(triggerEvent:TEventBase)
		if not settingsWindow then return False
		
		local dialogue:TGUIModalWindow = TGUIModalWindow(triggerEvent.GetSender())
		if dialogue <> settingsWindow.modalDialogue then return False

		if triggerEvent.GetData().GetInt("closeButton", -1) = 0
			ApplySettingsWindow()
		else
			print "cancel"
		endif
	End Function


	Function onClickCreateModalDialogue:Int(triggerEvent:TEventBase)
		CreateSettingsWindow()
	End Function


	Function CreateSettingsWindow()
		'load config
		local storage:TDataXmlStorage = new TDataXmlStorage
		storage.SetRootNodeKey("config")
		MyApp.configBase = storage.Load("settings.xml")
		MyApp.config = MyApp.configBase.copy().Append(storage.Load("settings.user.xml"))

		settingsWindow = new TSettingsWindow.Init()
	End Function


	Function ApplySettingsWindow()
		local config:TData = MyApp.config.copy()
		'append values stored in gui elements
		config.Append(settingsWindow.ReadGuiValues())
		
		'save the data differing to the default config
		'that "-" sets libxml to output the content instead of writing to
		'a file. Normally you should write to "test.user.xml" to overwrite
		'the users customized settings

		'remove "DEV_" ignore key so they get stored too
		local storage:TDataXmlStorage = new TDataXmlStorage
		storage.SetRootNodeKey("config")
		storage.SetIgnoreKeysStartingWith("")
		storage.Save("settings.user.xml", config.GetDifferenceTo(MyApp.configBase))
	End Function


	Method PrepareStart:Int()
		Super.PrepareStart()
		CreateSettingsWindow()
	End Method


	Method Update:Int()
		GuiManager.Update(self.name)
	End Method


	Method Render:int()
		Cls
		GetSpriteFromRegistry("gfx_startscreen").Draw(0,0)

		GuiManager.Draw(self.name)
	End Method
End Type




'kickoff
MyApp.SetTitle("Settingsdemo")
MyApp.Run()

