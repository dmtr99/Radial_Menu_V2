; This scripts creates a radial menu / pie menu
; The selected menu item is returned as a string.
; mbutton is used in this example to trigger the menu

#SingleInstance Force
#Requires AutoHotkey v2.0-beta.3
;#NoEnv


#Include Radial_Menu.ahk

mButton::
{
    GMenu := Radial_Menu()

    ; Settings for dark mode
    GMenu.ColorBackGround := "252526"
    GMenu.ColorLineBackGround := "454545"
    GMenu.ColorSelected := "08395D"
    GMenu.ColorLineSelected := "08395D"
    GMenu.ColorText := "ffffff"

    GMenu.SetSections("8")
    GMenu.Add("Save", "Images/analysis_meas_distance16.gif", 1, (*)=> (MsgBox("ds")))
    GMenu.Add("Save2", "Images/smt_flat_wall_mt.gif", 2)
    GMenu.Add2("Save2special", "Images/analysis_meas_distance16.gif", 2)
    GMenu.SetKey("mbutton")
    GMenu.SetKeySpecial("Ctrl")
    GMenu.Add("Save3", "", 3)
    GMenu.Add("Save4", "Images/smt_flat_wall_mt.gif", 4)
    GMenu.Add("Save5", "Images/smt_flat_wall_mt.gif", 5)
    GMenu.Add2("Save5se", "Images/fbcp_asm_image.gif", 5)
    GMenu.Add("Save6", "Images/smt_flat_wall_mt.gif", 6)
    GMenu.Add("", "", 7)
    GMenu.Add("Save8", "Images/smt_flat_wall_mt.gif", 8)
    Result := GMenu.Show()

    ; This Result string can be used in if else statements, in this demo i just use a message box.
    MsgBox(Result)
}
; return
