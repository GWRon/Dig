SuperStrict

'keep it small
Framework BRL.standardIO
Import "../../base.util.data.xmlstorage.bmx"

local storage:TDataXmlStorage = new TDataXmlStorage
storage.SetRootNodeKey("config")

'load default config
local configBase:TData = storage.Load("test.xml")
'load custom config
local configUser:TData = storage.Load("test.user.xml")
'merge to a useable "total" config
local config:TData = configBase.copy().Append(configUser)

print "BASE:"
print configBase.ToString()
print "------------"
print "USER:"
print configUser.ToString()
print "------------"
print "CONFIG:"
print config.ToString()
print "------------"
print "SAVE:"

'save the data differing to the default config
'that "-" sets libxml to output the content instead of writing to
'a file. Normally you should write to "test.user.xml" to overwrite
'the users customized settings

'remove "DEV_" ignore key so they get stored too
storage.SetIgnoreKeysStartingWith("")
storage.Save("-", config.GetDifferenceTo(configBase))
