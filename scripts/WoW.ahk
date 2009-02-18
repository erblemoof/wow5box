; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Chorizotarian

#NoEnv
#SingleInstance force

SendMode Input
SetWorkingDir %A_ScriptDir%

;**************************************************************************************************
; Functions
;**************************************************************************************************

;-------------------------------------
; Key Broadcasting
;-------------------------------------

; Send a string to a specific WoW instance
SendWow(iWow, strKeys)
{
    localPid := pid%iWow%
    IfWinNotActive, ahk_pid %localPid%
        ControlSend, , %strKeys%, ahk_pid %localPid%
}

; Send a string to the main (WoW index 1)
SendMain(strKeys)
{
	SendWow(1, strKeys)
}

; Send a string to the clones (WoW index 2+)
SendClones(strKeys)
{
    global nPids
    nClones := nPids-1
    Loop, %nClones%
    {
        iClone := A_Index + 1
	    SendWow(iClone, strKeys)
	}
}

; Send a string to everyone
SendAll(strKeys)
{
    global nPids
    Loop, %nPids%
    {
	    SendWow(A_Index, strKeys)
	}
}

; Send a string to a specific WoW instance, don't check focus
ForceWow(iWow, strKeys)
{
    localPid := pid%iWow%
    ControlSend, , %strKeys%, ahk_pid %localPid%
}

; Send a raw string to a specific WoW instance, don't check focus
ForceWowRaw(iWow, strKeys)
{
    localPid := pid%iWow%
    ControlSendRaw, , %strKeys%, ahk_pid %localPid%
}

; Send a string to the clones (WoW index 2+), don't check focus
ForceClones(strKeys)
{
    global nPids
    nClones := nPids-1
    Loop, %nClones%
    {
        iClone := A_Index + 1
	    ForceWow(iClone, strKeys)
	}
}

; Send a string to the clones (WoW index 2+), don't check focus
ForceClonesRaw(strKeys)
{
    global nPids
    nClones := nPids-1
    Loop, %nClones%
    {
        iClone := A_Index + 1
	    ForceWowRaw(iClone, strKeys)
	}
}

; Send a string to everyone, don't check focus
ForceAll(strKeys)
{
    global nPids
    Loop, %nPids%
    {
	    ForceWow(A_Index, strKeys)
	}
}

; Send a string to everyone, don't check focus
ForceAllRaw(strKeys)
{
    global nPids
    Loop, %nPids%
    {
	    ForceWowRaw(A_Index, strKeys)
	}
}

;-------------------------------------
; Movement / Formations
;-------------------------------------

; Spread out into a line: 2 3 1 4 5
BeginSpreadLine()
{
    SendWow(2, "{Q down}")
    SendWow(3, "{NumpadDiv down}{NumpadDiv up}{Q down}")
    SendWow(4, "{NumpadDiv down}{NumpadDiv up}{E down}")
    SendWow(5, "{E down}")
}

EndSpreadLine()
{
    SendWow(2, "{Q up}")
    SendWow(3, "{NumpadDiv down}{NumpadDiv up}{Q up}")
    SendWow(4, "{NumpadDiv down}{NumpadDiv up}{E up}")
    SendWow(5, "{E up}")
}

; Spread out into a box with 1 at the center
BeginSpreadBox()
{
    SendWow(2, "{Q down}{W down}")
    SendWow(3, "{Q down}{S down}")
    SendWow(4, "{E down}{W down}")
    SendWow(5, "{E down}{S down}")
}

EndSpreadBox()
{
    SendWow(2, "{Q up}{W up}{NumpadMult down}{NumpadMult up}")
    SendWow(3, "{Q up}{S up}{NumpadMult down}{NumpadMult up}")
    SendWow(4, "{E up}{W up}{NumpadMult down}{NumpadMult up}")
    SendWow(5, "{E up}{S up}{NumpadMult down}{NumpadMult up}")
    SendWow(2, "{S down}{S up}")
    SendWow(3, "{S down}{S up}")
    SendWow(4, "{S down}{S up}")
    SendWow(5, "{S down}{S up}")
}

;**************************************************************************************************
; Startup
;**************************************************************************************************

pidStr = %1%
password = %2%

; Get WoW process IDs from input params
nPids = 0
Loop, parse, pidStr, `,
{
    ++nPids
    
    pid%nPids% := A_LoopField
}

; Create a window group containing all WoW instances
Loop, %nPids%
{
    localPid := pid%A_Index%
    GroupAdd, wowGroup, ahk_pid %localPid%
}

;**************************************************************************************************
; Hotkeys
;**************************************************************************************************

#IfWinActive, ahk_group wowGroup

;-------------------------------------
; Special Functions
;-------------------------------------

Pause::Suspend, Toggle
~/::Suspend, On
~Enter::Suspend, Off

#r::
Suspend, On
ForceAll("{/}{r}{l}{Enter}")
Suspend, Off
Return

#p::
ForceAllRaw(password)
ForceAll("{Enter}")
Return

#Enter::ForceAll("{Enter}")

#x::ForceAllRaw("/exit")

XButton1::ForceAll("{Numpad0 down}{Numpad0 up}") ; force assist
XButton2::ForceAll("{NumpadMult down}{NumpadMult up}") ; follow

;-------------------------------------
; Movement / Formations
;-------------------------------------

;XButton1::BeginSpreadLine()
;XButton1 Up::EndSpreadLine()

{::ForceClones("{W down}")
{ Up::ForceClones("{W up}")

^{::BeginSpreadLine()
^{ Up::EndSpreadLine()

}::ForceClones("{S down}")
} Up::ForceClones("{S up}")

|::BeginSpreadBox()
| Up::EndSpreadBox()

; all jump
^MButton::ForceAll("{MButton down}{MButton up}")

;-------------------------------------
; Unmodified Hotkeys
;-------------------------------------

~*1::SendAll("{1 down}{1 up}")
~*2::SendAll("{2 down}{2 up}")
~*3::SendAll("{3 down}{3 up}")
~*4::SendAll("{4 down}{4 up}")
~*5::SendAll("{5 down}{5 up}")
~*6::SendAll("{6 down}{6 up}")
~*7::SendAll("{7 down}{7 up}")
~*8::SendAll("{8 down}{8 up}")
~*9::SendAll("{9 down}{9 up}")
~*0::SendAll("{0 down}{0 up}")
~*-::SendAll("{- down}{- up}")
~*=::SendAll("{= down}{= up}")
~*[::SendAll("{[ down}{[ up}")
~*]::SendAll("{] down}{] up}")
~*,::SendAll("{, down}{, up}")
~*.::SendAll("{. down}{. up}")

~F1::SendAll("{F1 down}{F1 up}")
~F2::SendAll("{F2 down}{F2 up}")
~F3::SendAll("{F3 down}{F3 up}")
~F4::SendAll("{F4 down}{F4 up}")
~F5::SendAll("{F5 down}{F5 up}")
~F6::SendAll("{F6 down}{F6 up}")
~F7::SendAll("{F7 down}{F7 up}")
~F8::SendAll("{F8 down}{F8 up}")
~F9::SendAll("{F9 down}{F9 up}")
~F10::SendAll("{F10 down}{F10 up}")
~F11::SendAll("{F11 down}{F11 up}")
~F12::SendAll("{F12 down}{F12 up}")

~F::SendAll("{F down}{F up}")

~*Numpad1::SendAll("{Numpad1 down}{Numpad1 up}")
~*Numpad2::SendAll("{Numpad2 down}{Numpad2 up}")
~*Numpad3::SendAll("{Numpad3 down}{Numpad3 up}")
~*Numpad4::SendAll("{Numpad4 down}{Numpad4 up}")
~*Numpad5::SendAll("{Numpad5 down}{Numpad5 up}")
~*Numpad6::SendAll("{Numpad6 down}{Numpad6 up}")
~*Numpad7::SendAll("{Numpad7 down}{Numpad7 up}")
~*Numpad8::SendAll("{Numpad8 down}{Numpad8 up}")

;-------------------------------------
; Shift (+) + Hotkey
;-------------------------------------

~+F1::SendAll("{Shift down}{F1 down}{F1 up}{Shift up}")
~+F2::SendAll("{Shift down}{F2 down}{F2 up}{Shift up}")
~+F3::SendAll("{Shift down}{F3 down}{F3 up}{Shift up}")
~+F4::SendAll("{Shift down}{F4 down}{F4 up}{Shift up}")
~+F5::SendAll("{Shift down}{F5 down}{F5 up}{Shift up}")

;-------------------------------------
; Modifiers
;-------------------------------------

~Control::SendAll("{Control down}")
~Control Up::SendAll("{Control up}")

~Alt::SendAll("{Alt down}")
~Alt Up::SendAll("{Alt up}")

;**************************************************************************************************
; GUI
;**************************************************************************************************

