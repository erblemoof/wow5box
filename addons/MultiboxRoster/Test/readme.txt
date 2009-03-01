Test Setup:
1) Download LUA standalone from http://luabinaries.luaforge.net/download.html
2) [optional] Add LUA bin folder to your path
3) [optional] Create a PowerShell alias lua => lua5.1.exe
4) Run PowerShell or cmd.exe
5) cd to this directory
6) {lua} ActionBarTargetingTests.lua, where {lua} is either the alias from 3 or the full path

Results should look something like this:

test> lua .\MultiboxRosterTests.lua
>>>>>>>>> MbrTests
>>> MbrTests:test_CreateMacro

=========================================================
Success : 100% - 1 / 1