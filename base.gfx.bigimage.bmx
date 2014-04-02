SuperStrict
Import "base.gfx.imagehelper.bmx"



Const MINFRAGSIZE:Int = 64 ' maximum image fragment size
Const MAXFRAGSIZE:Int = 256 ' maximum image fragment size
Type TImageFragment

    Field img:TImage
    Field x:Float,y:Float,w:Float,h:Float

    ' ----------------------------------
    ' constructor
    ' ----------------------------------
    Function Create:TImageFragment(pmap:TPixmap,x:Float,y:Float,w:Float,h:Float)

        Local frag:TImageFragment = New TImageFragment
        frag.img = LoadImage(PixmapWindow(pmap,x,y,w,h),0) '|FILTEREDIMAGE)
        frag.x = x
        frag.y = y
        frag.w = w
        frag.h = h

        Return frag

    End Function


    'Draw individual tile
    Method Render(xOffset:Float=0, yOffset:Float=0, Scale:Float=1.0)
	    Local vx:Int, vy:Int, vh:Int
	    GetViewport(vx,vy,vx,vh)
		If yOffset + Scale * y + h > 0 And yOffset + Scale * y < vy + vh
			DrawImage(img, xOffset + Scale * x, yOffset + Scale * y)
		EndIf
    End Method


    Method RenderInViewPort(xOffset:Float=0, yOffset:Float=0, vx:Float, vy:Float, vw:Float, vh:Float)
		'DrawSubImageRect(img, x + xOffset, y + yOffset, vw, vh, vx, vy, vw, vh, 0, 0, 0)

		ClipImageToViewport(img, x + xOffset, y + yOffset, vx, vy, vw, vh, 0, 0, 0)
	End Method

End Type




Type TBigImage
    Field pixmap:TPixmap
    Field px:Float, py:Float
    Field fragments:TList
    Field width:Float
    Field height:Float
	Field PixFormat:Int
    Field x:Float = 0
    Field y:Float = 0


	Function CreateFromImage:TBigImage(i:TImage)
		Local pix:TPixmap = i.pixmaps[0]
		Return TBigImage.Create(pix)
	End Function


	Function CreateFromPixmap:TBigImage(i:TPixmap)
		Return TBigImage.Create(i)
	End Function


	Function Create:TBigImage(p:TPixmap)
		Local bi:TBigImage = New TBigImage
		bi.pixmap = p
		bi.width = p.width
		bi.height = p.height
		bi.fragments = CreateList()
		bi.Load()
		bi.PixFormat = p.format
		bi.pixmap = Null
		Return bi
    End Function


    Method RestorePixmap:TPixmap()
		Local Pix:TPixmap = TPixmap.Create(width, height, PixFormat)
		For Local ImgFrag:TImageFragment = EachIn fragments
			DrawImageOnImage(ImgFrag.img, Pix, ImgFrag.x, ImgFrag.y)
		Next
		Return Pix
	End Method


	' -------------------------------------
    ' convert pixmap into image fragments
    ' -------------------------------------
    Method Load()
		'Print "Adding Fragments..."

        Local px:Float = 0
        Local py:Float = 0
        Local loading:Byte = True

        While (loading)
            Local w:Int = MAXFRAGSIZE
            Local h:Int = MAXFRAGSIZE
            If pixmap.width - px < MAXFRAGSIZE w = pixmap.width - px
            If pixmap.Height - py < MAXFRAGSIZE h = pixmap.Height - py
            Local f1:TImageFragment = TImageFragment.Create(pixmap, px, py, w, h)
			'Print "Added Fragment: w" + w + " h" + h
            ListAddLast fragments, f1
            px:+MAXFRAGSIZE
            If px >= pixmap.width
                px = 0
                py:+MAXFRAGSIZE
                If py >= pixmap.height loading = False
            EndIf
        Wend
    End Method


    'Draw entire image
    Method Render(x:Float = 0, y:Float = 0, Scale:Float = 1.0)
        For Local f:TImageFragment = EachIn fragments
            f.Render(x, y, Scale)
        Next
    End Method


    'Draw entire image limited by a viewport
    Method renderInViewPort(x:Float = 0, y:Float = 0, vx:Float, vy:Float, vw:Float, vh:Float)
        For Local f:TImageFragment = EachIn fragments
            f.RenderInViewPort(x, y, vx, vy, vw, vh)
        Next
    End Method
End Type