SuperStrict


Import sdl.gl2sdlmax2d

Import "base.util.graphicsmanagerbase.bmx"

Type TGraphicsManagerNG Extends TGraphicsManager

	Function GetInstance:TGraphicsManager()
		If Not _instance Then _instance = New TGraphicsManagerNG
		Return _instance
	End Function

	Method _InitGraphicsDefault:Int()
		Select renderer
			'buffered gl?
			'?android
			Default
				TLogger.Log("GraphicsManager.InitGraphics()", "SetGraphicsDriver ~qGL2SDL~q.", LOG_DEBUG)
				SetGraphicsDriver GL2Max2DDriver()
				renderer = RENDERER_GL2SDL
			'?Not android
		End Select

		_g = Graphics(realWidth, realHeight, colorDepth*fullScreen, hertz, flags)
	End Method


	Method EnableSmoothLines:Int()
		If renderer = RENDERER_OPENGL Or renderer = RENDERER_GL2SDL Or renderer = RENDERER_BUFFEREDOPENGL
			?Not android
			GlEnable(GL_LINE_SMOOTH)
			?
			Return True
		Else
			Return False
		EndIf
	End Method
End Type

'convenience function
Function GetGraphicsManager:TGraphicsManager()
	Return TGraphicsManagerNG.GetInstance()
End Function
