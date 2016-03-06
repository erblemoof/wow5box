This is my private SVN for WoW code, mostly for multiboxing. I regularly commit everything that I use, so you can pretty much see my whole setup by browsing the
[source](http://code.google.com/p/wow5box/source/browse/#svn/trunk).

## Addons ##

  * ActionBarTargeting: Automatically creates focus-free targeting and follow macros for multibox teams
  * MultiboxRoster: Define teams of multibox characters
  * [Undercut](http://code.google.com/p/wow5box/wiki/Undercut): Finds the competing items at the Auction House so you can ruthlessly undercut them
  * [WowUnit](http://code.google.com/p/wow5box/source/browse/#svn/trunk/addons/WowUnit): [LuaUnit](http://phil.freehackers.org/programs/luaunit/index.html) extensions for out-of-game addon unit testing

## PowerShell Scripts ##

  * [New-Wow.ps1](http://code.google.com/p/wow5box/source/browse/trunk/scripts/New-Wow.ps1): Creates a symbolically linked copy of WoW in a new location. See [this thread](http://www.dual-boxing.com/forums/index.php?page=Thread&threadID=4854&s=9d40e2d9ffe5d9c761957d72b777e6e91095866d).
  * [Start-Wow.ps1](http://code.google.com/p/wow5box/source/browse/trunk/scripts/Start-Wow.ps1): Launches WoW instances, positions windows and logs in to the appropriate accounts.

Start-Wow has some external dependencies that I haven't checked in yet, so please contact me if you are thinking of using it.

## AutoHotkey ##

I use AHK for key broadcasting. My script is
[here](http://code.google.com/p/wow5box/source/browse/trunk/scripts/WoW.ahk). I'm not
completely happy with it, but it may be useful to someone.

## Macros ##

I save all of my multiboxing macros to this SVN. Feel free to grab anything that seems useful:
  * [Normal macros](http://code.google.com/p/wow5box/source/browse/#svn/trunk/macros)
  * I also use Cogwheel's [MacroSequence](http://www.wowinterface.com/downloads/info7911-MacroSequence.html) extensively. My `Sequences.lua` file is [here](http://code.google.com/p/wow5box/source/browse/trunk/macros/Sequences.lua).

## About Me ##

I'm a software developer in Seattle and a strictly casual WoW player. I multibox for
the technical challenge and because my in-game schedule is too inconsistent to deal
with a guild.

If you want to contact me you can send mail to Chorizotarian at gmail. I also hang out
semi-regularly on the [dual-boxing.com forums](http://www.dual-boxing.com/forums).

[![](https://www.paypal.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=FJVUV4S9GXX9U&lc=US&item_name=wow5box&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)