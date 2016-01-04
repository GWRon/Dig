Rem
	====================================================================
	Audio Stream Classes
	====================================================================

	Contains:

	- a manager "TDigAudioStreamManager" needed for regular updates of
	  audio streams (refill of buffers). If not used, take care to
	  manually call "update()" for each stream on a regular base. 
	- a basic stream class "TDigAudioStream" and its extension
	  "TDigAudioStreamOgg" to enable decoding of ogg files.



	====================================================================
	If not otherwise stated, the following code is available under the
	following licence:

	LICENCE: zlib/libpng

	Copyright (C) 2014-2016 Ronny Otto, digidea.de

	This software is provided 'as-is', without any express or
	implied warranty. In no event will the authors be held liable
	for any	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it
	and redistribute it freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you
	   must not claim that you wrote the original software. If you use
	   this software in a product, an acknowledgment in the product
	   documentation would be appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and
	   must not be misrepresented as being the original software.

	3. This notice may not be removed or altered from any source
	   distribution.
	====================================================================
ENDREM
SuperStrict
Import pub.freeaudio
Import Pub.OggVorbis
Import Brl.OggLoader
Import Brl.LinkedList
Import Brl.audio
Import Brl.freeaudioaudio
Import Brl.standardio
Import Brl.bank
Import "base.sfx.soundstream.c"


Extern
	Function StartDigAudioStreamManagerUpdateThread:Int()
	Function StopDigAudioStreamManagerUpdateThread:Int()

	Function RegisterDigAudioStreamManagerUpdateCallback( func() )
	Function RegisterDigAudioStreamManagerPrintCallback( func(chars:Byte Ptr) )
End Extern




Type TDigAudioStreamManager
	Field streams:TList = CreateList()
	Global externalThreadRunning:Int = False
	'USE MANUAL UPDATES?
	Global threaded:int = False

	Method Init()
		Print "TDigAudioStreamManager.Init()"
		If Not externalThreadRunning and threaded
			Print "  setting update callback"
			'register callbacks to C - should be done in manager
			RegisterDigAudioStreamManagerUpdateCallback( cbStreamUpdate )
			Print "  setting print callback"
			RegisterDigAudioStreamManagerPrintCallback( cbPrint )

			Print "  starting update thread"
			StartDigAudioStreamManagerUpdateThread()
			externalThreadRunning = True
		EndIf
	End Method


	Method AddStream:Int(stream:TDigAudioStream)
		streams.AddLast(stream)
		Return True
	End Method


	Method RemoveStream:Int(stream:TDigAudioStream)
		streams.Remove(stream)
		Return True
	End Method


	Method ContainsStream:Int(stream:TDigAudioStream)
		Return streams.Contains(stream)
	End Method


	'do not call this manually except you know what you do
	Method Update:Int()
		For Local stream:TDigAudioStream = EachIn streams
			stream.Update()
		Next
	End Method


	Function cbPrint:Int(chars:Byte Ptr)
		Print String.FromCString(chars)
	End Function


	Function cbStreamUpdate:Int()
		If Not DigAudioStreamManager Then Return False

		DigAudioStreamManager.Update()

		Return MilliSecs()
	End Function
End Type
Global DigAudioStreamManager:TDigAudioStreamManager = New TDigAudioStreamManager




'base class for audio streams
Type TDigAudioStream
	Field buffer:Int[]
	Field sound:TSound
	Field currentChannel:TChannel

	'amount of bytes read from the stream 
	Field bytesRead:int = 0

	'channel position might differ from the really played position
	'so better store a custom position property to avoid discrepancies
	'when pausing a stream
	Field playbackPosition:Int

	
	Field streaming:Int
	'temporary variable to calculate position changes since last update
	Field _lastPlaybackPosition:Int
	Field _lastHandledBufferIndex:Int = -1
	'channel position when audio started (to calculate read samples amount)
	Field _channelAudioStartPosition:Int = 0

	Field samplesRead:Int = 0
	'length of the total sound
	Field samplesCount:Int = 0

	Field bits:Int = 16
	Field freq:Int = 44100
	Field channels:Int = 2
	Field format:Int = 0
	Field loop:Int = False
	Field paused:Int = False
	Field bufferStates:Int[]

	'length of each chunk in positions/ints 
	Const chunkLength:Int = 1024
	'amount of chunks in one buffer
	Const bufferChunkCount:Int = 32
	'amount of buffers
	Const bufferCount:Int = 3
	Const BUFFER_STATE_UNUSED:Int = 0
	Const BUFFER_STATE_PLAYING:Int = 1
	Const BUFFER_STATE_BUFFERED:Int = 2


	Method Create:TDigAudioStream(loop:Int = False)
		?PPC
		If channels=1 Then format=SF_MONO16BE Else format=SF_STEREO16BE
		?X86
		If channels=1 Then format=SF_MONO16LE Else format=SF_STEREO16LE
		?

		'option A
		'audioSample = CreateAudioSample(GetBufferLength(), freq, format)

		'option B
		Self.buffer = New Int[GetTotalBufferLength()]
		Local audioSample:TAudioSample = CreateStaticAudioSample(Byte Ptr(buffer), GetTotalBufferLength(), freq, format)

		bufferStates = New Int[bufferCount]

		'driver specific sound creation
		CreateSound(audioSample)
	
		SetLooped(loop)

		Return Self
	End Method


	Method Clone:TDigAudioStream(deepClone:Int = False)
		Local c:TDigAudioStream = New TDigAudioStream.Create(Self.loop)
		Return c
	End Method


	'=== CONTAINING FREE AUDIO SPECIFIC CODE ===

	Method CreateSound:Int(audioSample:TAudioSample)
		'not possible as "Loadsound"-flags are not given to
		'fa_CreateSound, but $80000000 is needed for dynamic sounds
		Rem
			$80000000 = "dynamic" -> dynamic sounds stay in app memory
			sound = LoadSound(audioSample, $80000000)
		endrem

		'LOAD FREE AUDIO SOUND
		?BMXNG
		Local fa_sound:Byte Ptr = fa_CreateSound( audioSample.length, bits, channels, freq, audioSample.samples, $80000000 )
		?not BMXNG
		Local fa_sound:Int = fa_CreateSound( audioSample.length, bits, channels, freq, audioSample.samples, $80000000 )
		?
		sound = TFreeAudioSound.CreateWithSound( fa_sound, audioSample)
	End Method


	Method CreateChannel:TChannel(volume:Float)
		Reset()
		currentChannel = Cue()
		currentChannel.SetVolume(volume)
		Return currentChannel
	End Method


	Method GetChannel:TChannel()
		Return currentChannel
	End Method
	

	Method GetChannelPosition:Int()
		'to recognize if the buffer needs a new refill, the position of
		'the current playback is needed. TChannel does not provide that
		'functionality, streaming with it is not possible that way.
		If TFreeAudioChannel(currentChannel)
			Return TFreeAudioChannel(currentChannel).Position()
		EndIf
		Return 0
	End Method

	'=== / END OF FREE AUDIO SPECIFIC CODE ===


	'returns the size of the buffer in bytes (not samples)
	Method GetTotalBufferBytes:Int()
		Return GetTotalBufferLength() * channels * 2
	End Method


	'returns the length of all buffers ("array length")
	Method GetTotalBufferLength:Int()
		Return GetBufferLength() * bufferCount
	End Method


	Method GetTotalBufferChunkCount:Int()
		Return GetBufferChunkCount() * bufferCount
	End Method


	Method GetBufferChunkCount:Int()
		Return bufferChunkCount
	End Method


	Method GetBufferLength:Int()
		Return chunkLength * GetBufferChunkCount()
	End Method


	Method GetBufferIndex:Int(position:Int = -1)
		Return position / GetBufferLength()
		'Return (position / Float(GetTotalBufferLength())) * bufferCount
	End Method


	'returns the buffer index of the play position
	Method GetBufferPlayIndex:Int()
		Return GetBufferIndex( GetTotalBufferPlayPosition() )
	End Method


	'returns the buffer index of the write position
	Method GetBufferWriteIndex:Int()
		Return GetBufferIndex( GetTotalBufferWritePosition() )
	End Method
	

	Method GetPlaybackPosition:Int()
		Return playbackPosition mod GetLength()
	End Method


	'returns current write position within the complete buffer
	Method GetTotalBufferWritePosition:Int()
		Return (bytesRead / 4) Mod GetTotalBufferLength()
	End Method


	'returns current write position within the (single) buffer
	Method GetBufferWritePosition:Int()
		Return GetTotalBufferWritePosition() Mod GetBufferLength()
	End Method


	'returns the position of the currently played data
	Method GetTotalBufferPlayPosition:Int()
		Return GetChannelPosition() Mod GetTotalBufferLength()
	End Method


	'returns the position of the currently played data within the
	'(single) buffer
	Method GetBufferPlayPosition:Int()
		Return GetTotalBufferPlayPosition() Mod GetBufferLength()
	End Method


	Method GetTimeLeft:Float()
		Return (samplesCount - GetPlaybackPosition()) / Float(freq)
	End Method


	Method GetTimePlayed:Float()
		Return GetPlaybackPosition() / Float(freq)
	End Method
	

	Method GetTimeBuffered:Float()
		Return (GetPlaybackPosition() + GetBufferWritePosition()) / Float(freq)
	End Method


	Method GetTimeTotal:Float()
		Return samplesCount / Float(freq)
	End Method


	Method GetProgress:Float()
		If samplesCount = 0 Then Return 0
		Return GetPlaybackPosition() / Float(samplesCount)
	End Method


	Method GetLength:Int()
		Return samplesCount
	End Method
	

	Method Delete()
		'int arrays get cleaned without our help
		'so only free the buffer if it was MemAlloc'ed 
		'if GetBufferSize() > 0 then MemFree buffer
	End Method


	Method ReadyToPlay:Int()
		Return Not streaming And GetBufferWriteIndex() > 0
	End Method


	Method EmptyBuffer:Int(offset:Int, length:Int = -1)
	End Method


	Method FillBuffer:Int(offset:Int, length:Int = -1)
	End Method


	Method ResetAudioData:Int()
		samplesRead = 0
		bytesRead = 0
	End Method


	Method ResetPlayback:Int()
		playbackPosition = 0
		_lastPlaybackPosition = 0
		_lastHandledBufferIndex = -1
	End Method

	'begin again
	Method Reset:Int()
		ResetAudioData()
		ResetPlayback()

		streaming = False
	End Method


	Method GetName:String()
		Return "unknown (TDigAudioStream)"
	End Method


	Method IsPaused:Int()
		'we cannot use "channelStatus & PAUSED" as the channel gets not
		'paused but the stream!
		'16 is the const "PAUSED" in freeAudio
		'return (fa_ChannelStatus(faChannel) & 16)

		Return paused
	End Method


	Method PauseStreaming:Int(bool:Int = True)
		paused = bool
		GetChannel().SetPaused(bool)
	End Method


	Method SetLooped(bool:Int = True)
		loop = bool
	End Method


	Method FinishPlaying:Int()
		Print "FinishPlaying: " + GetName()
		Reset()
		PauseStreaming()
	End Method


	Method Play:TChannel(reUseChannel:TChannel = Null)
		Print "Play: " + GetName()

		'load initial buffer - preload + playback buffer
		FillBuffer(0, GetBufferLength())
		Print "  Loaded initial buffer"


		'init and start threads if not done yet
		DigAudioStreamManager.Init()
		
		If Not DigAudioStreamManager.ContainsStream(Self)
			DigAudioStreamManager.AddStream(Self)
		EndIf

		If Not reUseChannel Then reUseChannel = currentChannel
		currentChannel = PlaySound(sound, reUseChannel)

		 _channelAudioStartPosition = GetChannelPosition()

		Return currentChannel
	End Method


	Method Cue:TChannel(reUseChannel:TChannel = Null)
		If Not reUseChannel Then reUseChannel = currentChannel
		currentChannel = CueSound(sound, reUseChannel)

		 _channelAudioStartPosition = GetChannelPosition()

		Return currentChannel
	End Method


	Method Update()
		If isPaused() Then Return
		If currentChannel And Not currentChannel.Playing() Then Return

		'=== CALCULATE STREAM-PLAYBACK POSITION ===
		playbackPosition :+ GetChannelPosition() - _lastPlaybackPosition
		'keep the value as small as possible
		playbackPosition = playbackPosition mod GetLength()
		_lastPlaybackPosition = playbackPosition

		'Print "update  playbackPosition=" + playbackPosition + "  samplesRead=" + samplesRead+"/"+samplesCount


		'=== REFRESH BUFFERSTATES ===
		Local unusedCount:Int = 0
		For Local i:Int = 0 Until bufferCount
			If GetBufferPlayIndex() <> i
				If bufferStates[i] = BUFFER_STATE_PLAYING
					bufferStates[i] = BUFFER_STATE_UNUSED
				EndIf
			ElseIf bufferStates[i] <> BUFFER_STATE_PLAYING
				bufferStates[i] = BUFFER_STATE_PLAYING
			EndIf

			unusedCount :+ 1
		Next


		'=== SKIP FURTHER PROCESSING ? ===
		'nothing to do
		If GetBufferIndex(playbackPosition) = _lastHandledBufferIndex Then Return
		_lastHandledBufferIndex = GetBufferIndex(playbackPosition)

		'no buffer for refill available
		If unusedCount = 0 Then Print "NOTHING TO DO";Return


		'=== FINISH PLAYBACK IF END IS REACHED ===
		'did the playing position reach the last piece of the stream?
		'TODO
		'If playbackPosition >= samplesCount And Not loop
		'	FinishPlaying()
		'	Return
		'EndIf


		'=== REFILL BUFFERS ===
		For Local i:Int = 0 Until bufferCount
			'for playIndex = 1 this is: 2, 0
			'for playIndex = 2 this is: 0, 1
			Local index:Int = (GetBufferPlayIndex() + i + 1) Mod bufferCount
'print "buffer index = "+index+"  samplesRead:"+samplesRead+"/"+samplesCount
			If bufferStates[ index ] <> BUFFER_STATE_UNUSED Then Continue
			
			Local loadSamples:Int = Max(0, Min( GetBufferLength(), samplesCount - samplesRead))
			If loadSamples > 0
				'print "fillbuffer  offset=" + GetTotalBufferWritePosition() +" loadSamples="+loadSamples+"/"+GetBufferLength()
				FillBuffer(GetTotalBufferWritePosition(), loadSamples)

				'wasn't enough data for the buffer?
				'-> fill with silence or repeat
				If loadSamples <> GetBufferLength()
					Local fillSamples:Int = GetBufferLength() - loadSamples
					If loop
						Local bufferWritePosition:Int = GetTotalBufferWritePosition()
						Print "reset offset=" + bufferWritePosition +" fillSamples="+fillSamples
						ResetAudioData()
						_channelAudioStartPosition = GetChannelPosition()
						
						FillBuffer(bufferWritePosition, fillSamples)
					Else
						Print "empty buffer"
						EmptyBuffer(GetTotalBufferWritePosition(), fillSamples)
					EndIf
				EndIf
					

				bufferStates[ index ] = BUFFER_STATE_BUFFERED
			EndIf

			'reached end - reset stream and start again
			If loadSamples = 0
				Print "RESET: " + (samplesCount - loadSamples) 
				ResetAudioData()
			EndIf
		Next


		'=== BEGIN PLAYBACK IF BUFFERED ENOUGH ===
		If not streaming and ReadyToPlay() And Not IsPaused()
			Print "  Set streaming to true"
			If currentChannel Then currentChannel.SetPaused(False)
			streaming = True
		EndIf
	End Method
End Type



'extended audio stream to allow ogg file streaming
Type TDigAudioStreamOgg Extends TDigAudioStream
	Field stream:TStream
	Field bank:TBank
	Field uri:Object
	Field ogg:Byte Ptr
	

	Method Create:TDigAudioStreamOgg(loop:Int = False)
		Super.Create(loop)

		Return Self
	End Method


	Method CreateWithFile:TDigAudioStreamOgg(uri:Object, loop:Int = False, useMemoryStream:Int = False)
		Self.uri = uri
		'avoid file accesses and load file into a bank
		If useMemoryStream
			SetMemoryStreamMode()
		Else
			SetFileStreamMode()
		EndIf
		
		Reset()
	
		Create(loop)
		Return Self
	End Method


	Method Clone:TDigAudioStreamOgg(deepClone:Int = False)
		Local c:TDigAudioStreamOgg = New TDigAudioStreamOgg.Create(Self.loop)
		c.uri = Self.uri
		If Self.bank
			If deepClone
				c.bank = LoadBank(Self.bank)
				c.stream = ReadStream(c.bank)
			'save memory and use the same bank
			Else
				c.bank = Self.bank
				c.stream = ReadStream(c.bank)
			EndIf
		Else
			c.stream = ReadStream(c.uri)
		EndIf

		c.Reset()
		
		Return c
	End Method


	Method SetMemoryStreamMode:Int()
		bank = LoadBank(uri)
		stream = ReadStream(bank)
	End Method


	Method SetFileStreamMode:Int()
		stream = ReadStream(uri)
	End Method


	Method ResetAudioData:Int()
		Super.ResetAudioData()
		If Not stream Then Return False
		'return to begin of raw data stream
		If ogg
			Read_Ogg(ogg, Null, 0) 'close
			stream.Seek(0)
			ogg = Decode_Ogg(stream, readfunc, seekfunc, closefunc, tellfunc, samplesCount, channels, freq)
		EndIf
	End Method


	'move to start, (re-)generate pointer to decoded ogg stream 
	Method Reset:Int()
		Super.Reset()

		'generate pointer object to decoded ogg stream
		ogg = Decode_Ogg(stream, readfunc, seekfunc, closefunc, tellfunc, samplesCount, channels, freq)
		If Not ogg Return False

		Return True
	End Method


	Method GetName:String()
		Return String(uri)+" (TDigAudioStreamOgg)"
	End Method


	Method EmptyBuffer:int(offset:Int, length:Int = -1)
		'length is given in "ints", so calculate length in bytes
		Local bytes:Int = 4 * length
		If bytes > GetTotalBufferBytes() Then bytes = GetTotalBufferBytes()

		Local bufAppend:Byte Ptr = Byte Ptr(buffer) + offset*4

		For Local i:Byte = 0 To bytes
			bufAppend[i] = 0
		Next
	End Method
	

	Method FillBuffer:Int(offset:Int, length:Int = -1)
		If Not ogg Then Return False

		'=== PREPARE PARAMS ===
		'length is given in "ints", so calculate length in bytes
		'and multiply with channels -> 2 * byte * channels = 4
		Local bytes:Int = Min(length*4, GetTotalBufferBytes() - offset*4)


		'=== FILL IN DATA ===
		Local bufAppend:Byte Ptr = Byte Ptr(buffer) + offset*4

print "fillbuffer()  stream.Pos="+stream.Pos()+"/"+stream.Size()+"  samplesRead="+samplesRead+"/"+samplesCount + "  offset="+offset+"  bytes="+bytes+"  length="+length+"/"+GetBufferLength()

		'try to read the oggfile at the current position
		Local result:Int = Read_Ogg(ogg, bufAppend, bytes)
		If result < 0
			Print "read_ogg: Error streaming from OGG"
			Throw "read_ogg: Error streaming from OGG"
		elseif result = 0
			'take care that you use the patched
			'pub.mod/oggvorbis.mod/oggvorbis.bmx
			'which returns results > 0 for successful reads
			print "read_ogg: REACHED END OF FILE"
		else
'			print "read_ogg: "+result+"/"+bytes+" bytes read"
		EndIf
		samplesRead :+ (result / 4) 'as int
		bytesRead :+ result

		Return result
	End Method


	'adjusted from brl.mod/oggloader.mod/oggloader.bmx
	'they are "private" there... so this is needed to expose them
	Function readfunc:Int( buf:Byte Ptr, size:Int, nmemb:Int, src:Object )
		Return TStream(src).Read(buf, size * nmemb) / size
	End Function


	Function seekfunc:Int(src_obj:Object, off0:Int, off1:Int, whence:Int)
		Local src:TStream=TStream(src_obj)
	?X86
		Local off:Int = off0
	?PPC
		Local off:Int = off1
	?
		Local res:Int = -1
		Select whence
			Case 0 'SEEK_SET
				res = src.Seek(off)
			Case 1 'SEEK_CUR
				res = src.Seek(src.Pos()+off)
			Case 2 'SEEK_END
				res = src.Seek(src.Size()+off)
		End Select
		If res >= 0 Then Return 0
		Return -1
	End Function


	Function closefunc(src:Object)
		
	End Function
	

	Function tellfunc:Int(src:Object)
		Return TStream(src).Pos()
	End Function
End Type
