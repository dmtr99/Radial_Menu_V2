#Requires AutoHotkey v2.0-beta.3
#Include Gdip_All.ahk
Class Radial_Menu {
    __New() {
        This.Sections := "4"
        This.RM_Key := "Capslock"
        This.Sect := Map()

        This.Sect_Name := Map()
        This.Sect_Img := Map()
        This.Sect_Name2 := Map()
        This.Sect_Img2 := Map()
        This.ColorBackGround := "FCFCFC"
        This.ColorLineBackGround := "C6DFFC"
        This.ColorSelected := "C6DFFC"
        This.ColorLineSelected := "F5E5D6"
        This.Radius := "100"
        This.ColorText := "000000"
        This.ColorSelectedText := "000000"
        This.Font := "Arial"
    }

    SetSections(Sections) {
        This.Sections := Sections
    }
    SetKey(RM_Key) {
        This.RM_Key := RM_Key
    }
    SetKeySpecial(RM_Key2) {
        This.RM_Key2 := RM_Key2
    }

    SetMode(mode){
        switch mode {
            case "Dark":
            {
                This.ColorBackGround := "252526"
                This.ColorLineBackGround := "454545"
                This.ColorSelected := "08395D"
                This.ColorLineSelected := "08395D"
                This.ColorText := "cccccc"
                This.ColorSelectedText := "ffffff"
            }
            case "Blue":
            {
                This.ColorBackGround := "17639A"
                This.ColorLineBackGround := "17639A"
                This.ColorSelected := "1C78B9"
                This.ColorLineSelected := "1C78B9"
                This.ColorText := "ffffff"
                This.ColorSelectedText := "ffffff"
            }
            case "Light":
            {
                This.ColorBackGround := "FCFCFC"
                This.ColorLineBackGround := "C6DFFC"
                This.ColorSelected := "C6DFFC"
                This.ColorLineSelected := "F5E5D6"
                This.ColorText := "000000"
                This.ColorSelectedText := "000000"
            }
            default:
            {
                throw Error("The mode [" mode "] is not defined." )
            }
        }
    }

    Add(SectionName, SectionImg, ArcNr, CallBack:="") {
        if !HasProp(This.Sect,ArcNr){
            This.Sect.%ArcNr% := Map()
        }
        if (SectionImg!=""){
            This.Sect.%ArcNr%.Img := SectionImg
        }

        This.Sect.%ArcNr%.CallBack := CallBack
        This.Sect.%ArcNr%.Name := SectionName
        if (This.Sections < ArcNr) {
            This.Sections := ArcNr
        }

    }
    Add2(SectionName2, SectionImg2, ArcNr, CallBack:="") {
        if !HasProp(This.Sect, ArcNr) {
            This.Sect.%ArcNr% := Map()
        }
        if (SectionImg2 != "") {
            This.Sect.%ArcNr%.Img2 := SectionImg2
        }
        This.Sect.%ArcNr%.CallBack2 := CallBack
        This.Sect.%ArcNr%.Name2 := SectionName2
        if (This.Sections < ArcNr) {
            This.Sections := ArcNr
        }
    }

    Show() {
        static
        SectName := ""
        CoordMode "Mouse", "Screen"
        MouseGetPos(&X_Center, &Y_Center)
        WinGetPos(&X_Win, &Y_Win, , , "A")
        R_1 := This.Radius
        R_2 := R_1 * 0.2
        Offset := 2
        R_3 := R_1 + Offset * 2 + 10

        X_Gui := X_Center - R_3
        Y_Gui := Y_Center - R_3
        Height_Gui := R_3 * 2
        Width_Gui := R_3 * 2

        Width := R_3 * 2
        height := R_3 * 2

        ; Destroying old menu if exists
        if WinExist("RM_Menu") {
          WinClose("RM_Menu")
        }

        ; Start gdi+
        global pToken
        If !pToken := Gdip_Startup() {
            MsgBox("Gdiplus failed to start.Please ensure you have gdiplus on your system", , 48)
            ExitApp
        }
        OnExit((ExitReason, ExitCode) => Gdip_Shutdown(pToken))


        ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
        Gui_Radial_Menu := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")

        ; Show the window
        Gui_Radial_Menu.Title := "RM_Menu"
        Gui_Radial_Menu.Show("NA x" . X_Gui . " y" . Y_Gui . " w" . Width_Gui . " h" . Height_Gui)

        ; Get a handle to this window we have created in order to update it later
        hwnd1 := WinExist()

        Loop This.Sections {	;Setting Bitmap images of sections

            if HasProp(This.Sect.%A_Index%,"Img") {
                if FileExist(This.Sect.%A_Index%.Img) {
                    This.Sect.%A_Index%.pBitmap := Gdip_CreateBitmapFromFile(This.Sect.%A_Index%.Img)
                } else if (This.Sect.%A_Index%.Img != "" and IsObject(This.Sect.%A_Index%.Img)) {
                    This.Sect.%A_Index%.pBitmap := Gdip_CreateBitmapFromHBITMAP(This.Sect.%A_Index%.Img)
                }

                if HasProp(This.Sect.%A_Index%, "pBitmap"){
                    This.Sect.%A_Index%.bWidth := Gdip_GetImageWidth(This.Sect.%A_Index%.pBitmap)
                    This.Sect.%A_Index%.bHeight := Gdip_GetImageHeight(This.Sect.%A_Index%.pBitmap)
                }
            }

            if HasProp(This.Sect.%A_Index%, "Img2") {
                if FileExist(This.Sect.%A_Index%.Img2) {
                    This.Sect.%A_Index%.pBitmap2 := Gdip_CreateBitmapFromFile(This.Sect.%A_Index%.Img2)
                } else if (This.Sect.%A_Index%.Img2 != "" and IsObject(This.Sect.%A_Index%.Img2)) {
                    This.Sect.%A_Index%.pBitmap2 := Gdip_CreateBitmapFromHBITMAP(This.Sect.%A_Index%.Img2)
                }
                if HasProp(This.Sect.%A_Index%, "pBitmap2") {
                    This.Sect.%A_Index%.bWidth2 := Gdip_GetImageWidth(This.Sect.%A_Index%.pBitmap2)
                    This.Sect.%A_Index%.bHeight2 := Gdip_GetImageHeight(This.Sect.%A_Index%.pBitmap2)
                }
            }
        }

        Counter := 0
        loop This.Sections {	;Calculating Section Points
            SectionAngle := 2 * 3.141592653589793 / This.Sections * (A_Index - 1)

            This.Sect.%A_Index%.X_Bitmap := R_3 + (R_1 - 30) * cos(SectionAngle) - 8
            This.Sect.%A_Index%.Y_Bitmap := R_3 + (R_1 - 30) * sin(SectionAngle) - 8

            This.Sect.%A_Index%.PointsA := Gdip_GetPointsSection(R_3, R_3, R_1 + Offset * 2 + 10, R_1 + Offset * 2, This.Sections, Offset, A_Index)
            This.Sect.%A_Index%.Points := Gdip_GetPointsSection(R_3, R_3, R_1, R_2, This.Sections, Offset, A_Index)
        }

        ; Setting brushes and Pens
        pBrush := Gdip_BrushCreateSolid("0xFF" This.ColorBackGround)
        pBrushA := Gdip_BrushCreateSolid("0xFF" This.ColorSelected)
        pBrushC := Gdip_BrushCreateSolid("0X01" This.ColorBackGround)
        pPen := Gdip_CreatePen("0xFF" This.ColorLineBackGround, 1)
        pPenA := Gdip_CreatePen("0xD2" This.ColorLineSelected, 1)
        hdc := CreateCompatibleDC()

        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)

        RM_KeyState_D := 0
        Section_Mouse_Prev := -1
        X_Mouse_P := -1
        Y_Mouse_P := -1
        Gdip_FillEllipse(G, pBrushC, R_3 - R_1, R_3 - R_1, 2 * R_1, 2 * R_1)

        loop {
            RM_KeyState := GetKeyState(This.RM_Key, "P")
            RM_KeyState2 := GetKeyState(This.RM_Key2, "P")

            if !WinExist("RM_Menu") {
                Exit
            }
            if (RM_KeyState = 1) {
                RM_KeyState_D := 1
            }
            if (RM_KeyState = 0 and RM_KeyState_D = 1) {
                Section_Mouse := RM_GetSection(This.Sections, R_2, X_Center, Y_Center)
                SectName := (This.Sect.HasProp(Section_Mouse) and HasProp(This.Sect.%Section_Mouse%, "Name")) ? This.Sect.%Section_Mouse%.Name : ""
                if (Section_Mouse != 0) {
                    break
                }
                RM_KeyState_D := 0
            }
            if (GetKeyState("LButton")) {

                Section_Mouse := RM_GetSection(This.Sections, R_2, X_Center, Y_Center)
                SectName := Section_Mouse = 0 ? "" : HasProp(This.Sect.%Section_Mouse%, "Name") ? This.Sect.%Section_Mouse%.Name: ""
                break
            }
            if GetKeyState("Escape") {
                Section_Mouse := 0
                SectName := ""
                SectCallBack := ""
                break
            }
            CoordMode("Mouse", "Screen")
            MouseGetPos(&X_Mouse, &Y_Mouse)
            X_Rel := X_Mouse - X_Center
            Y_Rel := Y_Mouse - Y_Center
            Center_Distance := Sqrt(X_Rel * X_Rel + Y_Rel * Y_Rel)

            Section_Mouse := RM_GetSection(This.Sections, R_2, X_Center, Y_Center)

            if (Center_Distance > R_1) {
                break
            }
            if (Section_Mouse = 0 or Section_Mouse = "") {
                ToolTip()
                SectName := ""
                SectName_N := ""
                SectCallBack := ""
            }
            else {
                Counter++
                SectName_N := HasProp(This.Sect.%Section_Mouse%, "Name") ? This.Sect.%Section_Mouse%.Name : ""
                SectCallBack_N := HasProp(This.Sect.%Section_Mouse%, "CallBack") ? This.Sect.%Section_Mouse%.CallBack : ""
                SectName2 := HasProp(This.Sect.%Section_Mouse%,"Name2") ? This.Sect.%Section_Mouse%.Name2 : ""
                SectCallBack2 := HasProp(This.Sect.%Section_Mouse%, "CallBack2") ? This.Sect.%Section_Mouse%.CallBack2 : ""
                if (HasProp(This, "RM_Key2") and GetKeyState(This.RM_Key2, "P") and SectName2 != "") {
                    SectName_N := SectName2
                    SectCallBack_N := SectCallBack2
                }

                if ((X_Mouse_P != X_Mouse) or (Y_Mouse_P != Y_Mouse) or SectName_N != SectName or Counter > 500) {
                    SectName := SectName_N
                    SectCallBack := SectCallBack_N

                    MouseGetPos(&X_Mouse_P, &Y_Mouse_P)
                    if (Counter > 500) {
                        ToolTip(SectName_N)
                        Counter := 0
                    }

                }
            }
            if (Section_Mouse != Section_Mouse_Prev or A_Index = 1 or RM_KeyState2_Prev != RM_KeyState2) {	; Update GDIP

                Gdip_GraphicsClear(G)
                hbm := CreateDIBSection(Height_Gui, Height_Gui)	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
                hdc := CreateCompatibleDC()	; Get a device context compatible with the screen
                obm := SelectObject(hdc, hbm)	; Select the bitmap into the device context
                G := Gdip_GraphicsFromHDC(hdc)	; Get a pointer to the graphics of the bitmap, for use with drawing functions

                ; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
                Gdip_SetSmoothingMode(G, 4)
                Gdip_FillEllipse(G, pBrushC, R_3 - R_1, R_3 - R_1, 2 * R_1, 2 * R_1)

                loop This.Sections {
                    Section := This.Sect.%A_Index%
                    SectionAngle := 2 * 3.141592653589793 / This.Sections * (A_Index - 1)
                    if (Section.Name = "") {
                        continue
                    }
                    SectionColorText := This.ColorText
                    If (A_Index = Section_Mouse) {
                        Gdip_FillPolygon(G, pBrushA, Section.Points)
                        Gdip_DrawLines(G, pPenA, Section.Points)
                        Gdip_FillPolygon(G, pBrushA, Section.PointsA)
                        Gdip_DrawLines(G, pPenA, Section.PointsA)
                        SectionColorText := This.ColorSelectedText
                    } else {
                        Gdip_FillPolygon(G, pBrush, Section.Points)
                        Gdip_DrawLines(G, pPen, Section.Points)
                    }

                    if (GetKeyState(This.RM_Key2, "P") and (HasProp(Section, "Name2") or HasProp(Section, "pBitmap2"))) {
                        if (HasProp(Section, "pBitmap2")){
                            Gdip_DrawImage(G, Section.pBitmap2, Section.X_Bitmap, Section.Y_Bitmap, 16, 16 * Section.bHeight2 / Section.bWidth2, 0, 0, Section.bWidth2, Section.bHeight2)
                        } else if (HasProp(Section, "Name2") and Section.Name2 != ""){
                            Gdip_TextToGraphics(G, Section.Name2, "cff" SectionColorText " vCenter x" Section.X_Bitmap -20 + 8 " y" Section.Y_Bitmap -20 + 8,This.Font , 40, 40)
                        }
                    } else {
                        if HasProp(Section, "pBitmap"){
                            Gdip_DrawImage(G, Section.pBitmap, Section.X_Bitmap, Section.Y_Bitmap, 16, 16 * Section.bHeight / Section.bWidth, 0, 0, Section.bWidth, Section.bHeight)
                        } else if (HasProp(Section, "Name") and Section.Name != ""){
                            Gdip_TextToGraphics(G, Section.Name, "cff" SectionColorText " vCenter x" Section.X_Bitmap -20 + 8 " y" Section.Y_Bitmap -20 + 8,This.Font , 40, 40)
                        }
                    }
                }

                ; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
                ; So this will position our gui at (0,0) with the Width and Height specified earlier
                UpdateLayeredWindow(hwnd1, hdc, X_Gui, Y_Gui, Width, Height)

                SelectObject(hdc, obm)	; Select the object back into the hdc
                DeleteObject(hbm)	; Now the bitmap may be deleted
                DeleteDC(hdc)	; Also the device context related to the bitmap may be deleted
                Gdip_DeleteGraphics(G)	; The graphics may now be deleted
            }
            RM_KeyState2_Prev := RM_KeyState2
            Section_Mouse_Prev := Section_Mouse
        }

        Tooltip

        SelectObject(hdc, obm)	; Select the object back into the hdc
        DeleteObject(hbm)	; Now the bitmap may be deleted
        DeleteDC(hdc)	; Also the device context related to the bitmap may be deleted
        Gdip_DeleteGraphics(G)	; The graphics may now be deleted

        loop This.Sections {
            if HasProp(This.Sect.%A_Index%,"pBitmap"){
                Gdip_DisposeImage(This.Sect.%A_Index%.pBitmap)
            }
            if HasProp(This.Sect.%A_Index%, "pBitmap2") {
                Gdip_DisposeImage(This.Sect.%A_Index%.pBitmap2)
            }
        }

        Gdip_DeleteBrush(pBrushC)
        Gdip_DeleteBrush(pBrush)
        Gdip_DeleteBrush(pBrushA)
        Gdip_DeletePen(pPen)
        Gdip_DeletePen(pPenA)
        Gdip_Shutdown(pToken)

        Gui_Radial_Menu.Destroy()
        if (SectCallBack != ""){
            SectCallBack
        }
        Return SectName
    }
}

;#######################################################################

Gdip_GetPointsSection(X_Center, Y_Center, R_1, R_2, Sections, Offset, Section := "1") {
    Section := Section - 1
    SectionAngle := 2 * 3.141592653589793 / Sections
    R_2_Min := 4 * Offset / Sin(SectionAngle)
    R_2 := R_2 > R_2_Min ? R_2 : R_2_Min
    SweepAngle := ACos((R_1 * cos(SectionAngle / 2) + Offset * sin(SectionAngle / 2)) / R_1) * 2
    SweepAngle_2 := ACos((R_2 * cos(SectionAngle / 2) + Offset * sin(SectionAngle / 2)) / R_2) * 2

    Loop_Sections := round(R_1 * SweepAngle)
    StartAngle := -SweepAngle / 2 + SectionAngle * (Section)
    loop Loop_Sections {
        Angle := StartAngle + (A_Index - 1) * SweepAngle / (Loop_Sections - 1)
        X_Arc := round(X_Center + R_1 * cos(Angle))
        Y_Arc := round(Y_Center + R_1 * sin(Angle))
        if (A_Index = 1) {
            Points := X_Arc "," Y_Arc
            X_Arc_Start := X_Arc
            Y_Arc_Start := Y_Arc
            continue
        }
        Points .= "|" X_Arc "," Y_Arc
    }

    Loop_Sections := round(R_2 * SweepAngle_2)
    StartAngle_2 := SweepAngle_2 / 2 + SectionAngle * (Section)
    loop Loop_Sections {
        Angle := StartAngle_2 - (A_Index - 1) * SweepAngle_2 / (Loop_Sections - 1)
        X_Arc := round(X_Center + R_2 * cos(Angle))
        Y_Arc := round(Y_Center + R_2 * sin(Angle))
        Points .= "|" X_Arc "," Y_Arc
    }

    Points .= "|" X_Arc_Start "," Y_Arc_Start

    return Points
}

;#######################################################################

RM_GetSection(Sections, R_2, X_Center, Y_Center) {

    CoordMode("Mouse", "Screen")
    WinGetPos(&X_Win, &Y_Win, , , "RM_Menu")
    MouseGetPos(&X_Mouse, &Y_Mouse)

    X_Rel := X_Mouse - X_Center
    Y_Rel := Y_Mouse - Y_Center

    Distance_Center := Sqrt(X_Rel * X_Rel + Y_Rel * Y_Rel)
    Section_Mouse := ""
    X_Rel := X_Rel = 0 ? 0.01 : X_Rel ; (correction to prevent X to be 0)
    Y_Rel := Y_Rel = 0 ? 0.01 : Y_Rel ; (correction to prevent X to be 0)

    if (Distance_Center < R_2) {
        Section_Mouse := 0
    } else if (Distance_Center > R_2) {
        a := X_Rel = 0 ? (Y_Rel = 0 ? 0 : Y_Rel > 0 ? 90 : 270) : atan(Y_Rel / X_Rel) * 57.2957795130823209	; 180/pi
        Angle := X_Rel < 0 ? 180 + a : a < 0 ? 360 + a : a
        Section_Mouse := 1 + round(Angle / 360 * Sections)
        if (Section_Mouse > Sections) {
            Section_Mouse := 1
        }
    }

    return Section_Mouse
}
