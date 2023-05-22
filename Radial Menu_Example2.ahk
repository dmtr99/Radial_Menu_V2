; This scripts creates a radial menu / pie menu
; The selected menu item is returned as a string.
; mbutton is used in this example to trigger the menu

#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3
#Include <JSON>
#Include <ObjectGui>
;#NoEnv


#Include Radial_Menu.ahk

mRMenu := map()
mRMenu["Sections"] := 8
mRMenu["Mode"] := "Blue"
mRMenu["Menu"] := Array()
Loop mRMenu["Sections"] {
    mRMenu["Menu"].Push(Map())
}
mMenuItem := Map()
mMenuItem["Name"] :="Save"
mMenuItem["Img"] := "Images/analysis_meas_distance16.gif"
mMenuItem["CallBack"] :="Save"
mRMenu["Menu"][1] := mMenuItem
mMenuItem2 := Map()
mMenuItem2["Name"] :="Save2"
mMenuItem2["Img"] := "Images/hole16.gif"
mMenuItem2["CallBack"] :="Save2"
mRMenu["Menu"][2] := mMenuItem2
mMenuItem3 := Map()
mMenuItem3["Name"] :="Save3"
mMenuItem3["Img"] := "Images/dim_entity.gif"
mMenuItem3["CallBack"] :="Save3"
mRMenu["Menu"][6] := mMenuItem3


If (!pToken := Gdip_Startup()){
    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
    ExitApp
}
OnExit((ExitReason, ExitCode) => Gdip_Shutdown(pToken))

Gui1 := Gui("+AlwaysOnTop -DPIScale")
Gui1.Width := 1400
Gui1.Height := 1050

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Gui1.OnEvent("Close", Gui_Close)
Gui1.OnEvent("Escape", Gui_Close)
Gui1.AddText("x240 w80","Sections:")
ogSections := Gui1.AddEdit("x+10 w20",mRMenu["Sections"])
ogSections.OnEvent("Change",(*)=>(UpdateRadialMenu()))
ogMode := Gui1.AddDropDownList("x+10 w60 Choose1",["Light","Dark","Blue"])
ogMode.OnEvent("Change",(*)=>(UpdateRadialMenu()))
Gui1.AddGroupBox("x230 w360 r5","MenuItem")
Gui1.SectionA := 1
Gui1.AddText("x240 yp+24 w80","Name:")
ogName := Gui1.AddEdit("x+10 w250",mRMenu["Menu"][1]["Name"])
ogName.OnEvent("Change",(*)=>(UpdateRadialMenu()))
Gui1.AddText("x240 yp+24 w80","Img:")
ogImg := Gui1.AddEdit("x+10 w250",mRMenu["Menu"][1]["Img"])
ogImg.OnEvent("Change",(*)=>(UpdateRadialMenu()))
Gui1.AddText("x240 yp+24 w80","Command:")
; ogCommand := Gui1.AddEdit("x+10 w250",mRMenu["Menu"][1]["CallBack"])
ogCommand := Gui1.AddDropDownList("x+10 w250",["","Save","Save2","Save3"])
oGCommand.Text := mRMenu["Menu"][1]["CallBack"]
ogCommand.OnEvent("Change",(*)=>(UpdateRadialMenu()))


Gui1.Show("NA w600 h300")

Gui2 := Gui("+Parent" Gui1.hwnd " -Caption +E0x80000 +LastFound +ToolWindow +OwnDialogs")
Gui2.OnEvent("Close", Gui_Close)
Gui2.OnEvent("Escape", Gui_Close)
Gui2.Show("NA")

OnMessage(WM_LBUTTONDOWN := 0x0201, Click_BSelector)
UpdateRadialMenu()

UpdateRadialMenu(*){
    global

    mRMenu["Sections"] := ogSections.Text
    mRMenu["Mode"] := ogMode.text
    Index := Gui1.SectionA

    mRMenu["Menu"][Index]["Name"]:= ogName.Text
    mRMenu["Menu"][Index]["Img"]:= ogImg.Text
    mRMenu["Menu"][Index]["CallBack"]:= ogCommand.Text

    ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
    hbm := CreateDIBSection(Gui1.Width, Gui1.Height)

    ; Get a device context compatible with the screen
    hdc := CreateCompatibleDC()

    ; Select the bitmap into the device context
    obm := SelectObject(hdc, hbm)

    ; Get a pointer to the graphics of the bitmap, for use with drawing functions
    G2 := Gdip_GraphicsFromHDC(hdc)

    ; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
    Gdip_SetSmoothingMode(G2, 4)

    R_1 := 100
    R_2 := R_1 * 0.2
    Offset := 2
    R_3 := R_1 + Offset * 2 + 10

    switch mRMenu["Mode"] {
        case "Dark":
        {
            ColorBackGround := "252526"
            ColorLineBackGround := "454545"
            ColorSelected := "08395D"
            ColorLineSelected := "08395D"
            ColorText := "cccccc"
            ColorSelectedText := "ffffff"
        }
        case "Blue":
        {
            ColorBackGround := "17639A"
            ColorLineBackGround := "17639A"
            ColorSelected := "1C78B9"
            ColorLineSelected := "1C78B9"
            ColorText := "ffffff"
            ColorSelectedText := "ffffff"
        }
        case "Light":
        {
            ColorBackGround := "FCFCFC"
            ColorLineBackGround := "C6DFFC"
            ColorSelected := "C6DFFC"
            ColorLineSelected := "F5E5D6"
            ColorText := "000000"
            ColorSelectedText := "000000"
        }
    }

    Radius := "100"
    ColorText := "000000"
    ColorSelectedText := "000000"
    SectionColorText := ColorText

    Font := "Arial"

    pBrush := Gdip_BrushCreateSolid("0xFF" ColorBackGround)
    pBrushA := Gdip_BrushCreateSolid("0xFF" ColorSelected)
    pBrushC := Gdip_BrushCreateSolid("0X01" ColorBackGround)
    pPen := Gdip_CreatePen("0x88" ColorLineBackGround, 1)
    pPenA := Gdip_CreatePen("0xD2" ColorLineSelected, 1)


    Sections := ogSections.Text
    SectionA := Gui1.SectionA

    for MenuItem in mRMenu["Menu"]{

        if (mRMenu["Sections"]<A_Index){
            break
        }
        Index := A_Index

        SectionAngle := 2 * 3.141592653589793 / Sections * (Index - 1)
        X_Bitmap := R_3 + (R_1 - 30) * cos(SectionAngle) - 8
        Y_Bitmap := R_3 + (R_1 - 30) * sin(SectionAngle) - 8

        PointsA := Gdip_GetPointsSection(R_3, R_3, R_1 + Offset * 2 + 10, R_1 + Offset * 2, Sections, Offset, Index)
        Points := Gdip_GetPointsSection(R_3, R_3, R_1, R_2, Sections, Offset, Index)
        if (Index=SectionA){
            Gdip_FillPolygon(G2, pBrushA, Points)
            Gdip_DrawLines(G2, pPenA, Points)
        } else {
            Gdip_FillPolygon(G2, pBrush, Points)
            Gdip_DrawLines(G2, pPen, Points)
        }

        if (type(MenuItem)!="Map" or !MenuItem.Has("Name") or MenuItem["Name"] = ""){
            continue
        }

        if (MenuItem.Has("Img") and MenuItem["Img"]!=""){
            Img := MenuItem["Img"]
            if FileExist(Img) {
                pBitmap := Gdip_CreateBitmapFromFile(Img)
            } else if (Img != "" and IsObject(Img)) {
                pBitmap := Gdip_CreateBitmapFromHBITMAP(Img)
            } else {
                MsgBox("Error, Image [" Img "] was not found.")
            }

            bWidth := Gdip_GetImageWidth(pBitmap)
            bHeight := Gdip_GetImageHeight(pBitmap)

            if (bWidth=0){
                MsgBox("Error, Image [" Img "] had a bWidth of 0.`n" A_index)
            }

            Gdip_DrawImage(G2, pBitmap, X_Bitmap, Y_Bitmap, 16, 16 * bHeight / bWidth, 0, 0, bWidth, bHeight)
            ; Gdip_DisposeImage(pBitmap)
        } else {
            Gdip_TextToGraphics(G2, MenuItem["Name"], "cff" SectionColorText " vCenter x" X_Bitmap -20 + 8 " y" Y_Bitmap -20 + 8,Font , 40, 40)
            ; Gdip_DisposeImage(pBitmap)
        }

    }

    ; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
    ; So this will position our gui at (0,0) with the Width and Height specified earlier

    Gdip_DeleteBrush(pBrush)
    Gdip_DeleteBrush(pBrushA)
    Gdip_DeleteBrush(pBrushC)
    Gdip_DeletePen(pPen)
    Gdip_DeletePen(pPenA)

    UpdateLayeredWindow(Gui2.hwnd, hdc, 0, 0, Gui1.Width, Gui1.Height)
    SelectObject(hdc, obm)	; Select the object back into the hdc
    Gdip_ReleaseDC(G2, hdc)
    ; Gdip_DisposeImage(pBitmap)
    ; DeleteObject(hbm)
    ; Gdip_DeleteGraphics(G2)

}

Click_BSelector(*) {
    MouseGetPos( &X_Mouse, &Y_Mouse, &VarWin, &VarControlHwnd,2)
    R_1 := 100
    R_2 := R_1 * 0.2
    Offset := 2
    R_3 := R_1 + Offset * 2 + 10
    Sections := mRMenu["Sections"]
    Sections := ogSections.Text
    X_Center := R_3
    Y_Center := R_3
    X_Rel := X_Mouse - X_Center
    Y_Rel := Y_Mouse - Y_Center

    Distance_Center := Sqrt(X_Rel * X_Rel + Y_Rel * Y_Rel)
    Section_Mouse := ""
    X_Rel := X_Rel = 0 ? 0.01 : X_Rel ; (correction to prevent X to be 0)
    Y_Rel := Y_Rel = 0 ? 0.01 : Y_Rel ; (correction to prevent X to be 0)
    Section_Mouse := 0
    if (Distance_Center > R_2 and Distance_Center < R_1) {
        a := X_Rel = 0 ? (Y_Rel = 0 ? 0 : Y_Rel > 0 ? 90 : 270) : atan(Y_Rel / X_Rel) * 57.2957795130823209	; 180/pi
        Angle := X_Rel < 0 ? 180 + a : a < 0 ? 360 + a : a
        Section_Mouse := 1 + round(Angle / 360 * Sections)
        if (Section_Mouse > Sections) {
            Section_Mouse := 1
        }
    } else {
        return
    }
    Gui1.SectionA := Section_Mouse
    MenuItem := mRMenu["Menu"][Section_Mouse]
    ; ObjectGui(MenuItem)
    ogName.Text := (MenuItem != "" and MenuItem.Has("Name")) ? MenuItem["Name"] : ""
    ogImg.Text := (MenuItem != "" and MenuItem.Has("Img")) ? MenuItem["Img"] : ""
    ogCommand.Text := (MenuItem != "" and MenuItem.Has("CallBack")) ? MenuItem["CallBack"] : ""
    UpdateRadialMenu()
    return Section_Mouse
}

Gui_Close(*){
    global
    ; Delete the brush as it is no longer needed and wastes memory
    ; Select the object back into the hdc
    SelectObject(Gui2.hwnd, obm)
    ; Now the bitmap may be deleted
    DeleteObject(hbm)
    ; Also the device context related to the bitmap may be deleted
    DeleteDC(hdc)
    ; The graphics may now be deleted
    Gdip_DeleteGraphics(G2)
    Gdip_Shutdown(pToken)
    ExitApp
 }

F1::{

    RM_ShowCustomMenu(mRMenu)


}

RM_ShowCustomMenu(mRMenu){
    GMenu := Radial_Menu()

    ; Settings for dark mode
    if mRMenu.Has("Mode"){
        GMenu.SetMode(mRMenu["Mode"])
    }
    if mRMenu.Has("Font"){
        GMenu.Font := mRMenu["Font"]
    }
    GMenu.SetSections(mRMenu["Sections"])
    for key, mMenuItem in mRMenu["Menu"] {
        if (mRMenu["Sections"]<A_Index){
            break
        }
        if (mMenuItem.Has("Name")){
            GMenu.Add(mMenuItem["Name"], mMenuItem["Img"], A_Index, mMenuItem["CallBack"])
        }
    }

    Result := GMenu.Show()
}
Save(){
    MsgBox("Text")
}
Save2(){
    MsgBox("Text2")
}
Save3(){
    MsgBox("Text3")
}

; m::
; {
;     GMenu := Radial_Menu()

;     ; Settings for dark mode
;     GMenu.SetMode("Blue")

;     GMenu.SetSections("8")
;     GMenu.Add("Save", "Images/analysis_meas_distance16.gif", 1, (*)=> (MsgBox("Callbacktest")))
;     GMenu.Add("Save2", "Images/smt_flat_wall_mt.gif", 2)
;     GMenu.Add2("Save2special", "Images/analysis_meas_distance16.gif", 2, (*)=> (MsgBox("Callbacktest2")))
;     GMenu.SetKey("mbutton")
;     GMenu.SetKeySpecial("Ctrl")
;     GMenu.Add("Save3", "", 3)
;     GMenu.Add2("Save3ss", "", 3)
;     GMenu.Add("Save4", "Images/smt_flat_wall_mt.gif", 4)
;     GMenu.Add("Save5", "Images/smt_flat_wall_mt.gif", 5)
;     GMenu.Add2("Save5se", "Images/fbcp_asm_image.gif", 5)
;     GMenu.Add("Save6", "Images/smt_flat_wall_mt.gif", 6)
;     GMenu.Add("", "", 7)
;     GMenu.Add("Save8", "Images/smt_flat_wall_mt.gif", 8)
;     GMenu.Font := "Calibri"
;     Result := GMenu.Show()

;     ; This Result string can be used in if else statements, in this demo i just use a message box.
;     MsgBox(Result)
; }
