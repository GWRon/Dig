SuperStrict
Import "../../base.sfx.soundstream.bmx"
SetAudioDriver("FreeAudio")

'load some music
Local stream:TDigAudioStreamOgg = New TDigAudioStreamOgg.CreateWithFile("sound3.ogg", True)


Graphics 800, 600
SetColor 255,255,255


DigAudioStreamManager.AddStream(stream)
stream.Play()
While Not KeyHit(KEY_ESCAPE)
	Cls

	if not TDigAudioStreamManager.threaded
		DigAudioStreamManager.Update()
	endif

	SetColor 255,255,255
	DrawText("GCMemAlloced: "+GCMemAlloced(), 20,20)


	if stream
		Local soundWidth:Int = 760
		Local widthPerSecond:Float = soundWidth / stream.GetTimeTotal()

		SetColor 255,255,255
		DrawText("playbackPosition="+Rset(stream.GetPlaybackPosition(),7)+" / "+stream.samplesCount+"    samplesRead="+Rset(stream.samplesRead,7)+" /"+stream.samplesCount, 120, 280)
		DrawText(Left(stream.GetTimePlayed(),4) +" / "+ Left(stream.GetTimeTotal(),3), 20, 280)
		DrawRect(20,300, soundWidth, 25)
		SetColor 255,200,200
		DrawRect(20,300, Min(soundWidth, widthPerSecond * stream.GetTimeBuffered()), 25)

		SetColor 255,0,0
		DrawRect(20,300, Min(soundWidth, widthPerSecond * stream.GetTimePlayed()), 25)
		SetColor 255,255,255


		'buffers
		DrawText("Buffers:  playIndex="+stream.GetBufferPlayIndex()+"  writeIndex="+stream.GetBufferWriteIndex(), 20,345)
		For local i:int = 0 to 2
			if i = stream.GetBufferPlayIndex()
				SetColor 200,200,0
				DrawRect(20 + i*(soundWidth / 3) + 10, 362, 40, 5)
			endif
			if i = stream.GetBufferWriteIndex()
				SetColor 200,0,0
				DrawRect(20 + i*(soundWidth / 3) + 50, 362, 40, 5)
			endif

			Select stream.bufferStates[i]
				case TDigAudioStream.BUFFER_STATE_PLAYING
					SetColor 255,255,0
					DrawText("playing", 20 + i*(soundWidth / 3), 380)
				case TDigAudioStream.BUFFER_STATE_UNUSED
					SetColor 125,125,125
					DrawText("unused", 20 + i*(soundWidth / 3), 380)
				case TDigAudioStream.BUFFER_STATE_BUFFERED
					SetColor 0,255,0
					DrawText("buffered", 20 + i*(soundWidth / 3), 380)
			EndSelect
			DrawRect(20 + i*(soundWidth / 3) + 1, 365, soundWidth / 3 - 2, 15)

			SetColor 200,200,0
			DrawRect(20, 365+9, soundWidth * stream.GetTotalBufferPlayPosition()/Float(stream.GetTotalBufferLength()), 3)
			SetColor 200,0,0
			DrawRect(20, 365+12, soundWidth * stream.GetTotalBufferWritePosition()/Float(stream.GetTotalBufferLength()), 3)
		Next
		SetColor 255,255,255
	endif

	'delay output - so we see if the thread is refilling the buffer correctly
	Delay(100)

	'commenting this out, gets rid of the segfault when exiting the app
	Flip
Wend
