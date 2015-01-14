'Import brl.WAVLoader
Import brl.OGGLoader
Import "../../base.sfx.channelpool.bmx"

Graphics 800, 600, 0

'ATTENTION: use your own sounds here!
Global sound:TSound = LoadSound("sound1.ogg")
Global sound2:TSound = LoadSound("sound2.ogg")

if not sound then Throw "provide a valid OGG sound for ~qsound~q"
if not sound2 then Throw "provide a valid OGG sound for ~qsound2~q"

Repeat
	'enable this to see how only one channel is used
	'TChannelPool.channelLimit = 1
	'enable this to see an error thrown when trying to use other
	'channels than "soundchannel1"
	'ProtectPooledChannel("soundchannel1")
	
	if KeyHit(KEY_1) then PlaySound(sound, GetPooledChannel("soundchannel1"))
	if KeyHit(KEY_2) then PlaySound(sound2, GetPooledChannel("soundchannel1"))

	if KeyHit(KEY_3) then PlaySound(sound, GetPooledChannel("soundchannel2"))
	if KeyHit(KEY_4) then PlaySound(sound2, GetPooledChannel("soundchannel3"))

	if KeyHit(KEY_Q) then GetPooledChannel("soundchannel1").Stop()
	if KeyHit(KEY_W) then GetPooledChannel("soundchannel1").Stop()
	if KeyHit(KEY_E) then GetPooledChannel("soundchannel2").Stop()
	if KeyHit(KEY_R) then GetPooledChannel("soundchannel3").Stop()

	Cls

	local channel1:string = "unused"
	local channel2:string = "unused"
	local channel3:string = "unused"
	if GetPooledChannel("soundchannel1").Playing() then channel1 = "USED"
	if GetPooledChannel("soundchannel2").Playing() then channel2 = "USED"
	if GetPooledChannel("soundchannel3").Playing() then channel3 = "USED"

	DrawText("[1] .. play sound 1 on "+channel1+" channel 1", 10, 10+0*15)
	DrawText("[2] .. play sound 2 on "+channel1+" channel 1", 10, 10+1*15)
	DrawText("[3] .. play sound 1 on "+channel2+" channel 2", 10, 10+3*15)
	DrawText("[4] .. play sound 2 on "+channel3+" channel 3", 10, 10+4*15)
	DrawText("[Q] .. stop sound 1 on channel 1", 350, 10+0*15)
	DrawText("[W] .. stop sound 2 on channel 1", 350, 10+1*15)
	DrawText("[E] .. stop sound 1 on channel 2", 350, 10+3*15)
	DrawText("[R] .. stop sound 2 on channel 3", 350, 10+4*15)

	Flip 0
Until KeyHit(KEY_ESCAPE) or AppTerminate()