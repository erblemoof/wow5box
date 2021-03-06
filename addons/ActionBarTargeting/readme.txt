#summary World of Warcraft addon for painless, focus-free multibox targeting and follow

Downloads: http://code.google.com/p/wow5box/downloads/list

Discussion Thread: [http://www.dual-boxing.com/forums/index.php?page=Thread&postID=182715#post182715 dual-boxing.com]

== Updates ==

    * 3/4/09 (v0.3): Added focus as main on actionbar page 6

== Introduction ==

ActionBarTargeting is a WoW addon that automatically creates targeting and follow macros for a multibox team of
characters. The targeting system is based on the [http://www.wowwiki.com/Making_a_macro#Complete_list actionbar]
conditional (active actionbar page), so focus is kept free for defining crowd control targets.

Targeting macros are bound to invisible buttons that can be `/click`'ed to do the appropriate actions. For example,
the following macro clicks the ActionBarTargeting `SetOffensiveTarget` button to make one of your shaman followers
target your main's target before casting a Lightning Bolt:

{{{
/click SetOffensiveTarget
/cast Lightning Bolt
}}}

Team membership is defined using the companion addon MultiboxRoster, which recognizes team changes and fires an event.
Switching teams is as easy as logging on with the new characters and adding them to a party
or raid. ActionBarTargeting will automatically recognize the new team and update your targeting and follow commands.

To switch mains, just use whatever key your have bound to actionbar pages 1-5. For me this is F1-F5, but you can define
whatever keys you like using the standard WoW keybinds UI. You can use this mechanism to switch mains at any time,
including in combat. You can even switch mains in a macro using the
[http://www.wowwiki.com/MACRO_changeactionbar changeactionbar] slash command.

== How It Works ==

ActionBarTargeting creates the following macros/buttons:
    * `SetOffensiveTarget`: Instructs a clone to assist your main unless they already have a hostile target (sticky targeting).
    * `SetHealingTarget`: Clone targets your main's target (if friendly, not dead, etc.) or else your main.
    * `TargetMain`: Clone targets your main.
    * `TargetMainTarget`: Clone targets your main's target.
    * `FollowMain`: Clone follows your main.
    * `TargetToon{1-n}`: Targets characters 1-n in your team, irrespective of party position.
The macro for each button is slightly different for each character in a team. For example, take a team of 3 shamans:
Toon1, Toon2 and Toon3. Each shaman uses the Lightning Bolt macro shown above for their primary nuke. On shaman 1
`SetOffensiveTarget` looks like this:

{{{
/startattack
/stopmacro [exists,harm,nodead]
/assist [bar:2] Toon2; [bar:3] Toon3
}}}

With the current actionbar page set to 1, Toon1 is the main, so all this macro does is start his auto-attack. He he will
cast his lightning bolt as usual, at whatever he has targeted. (Note: `bar` is a short form for the `actionbar` conditional.)

On shaman 2 though, `SetOffensiveTarget` looks like this:

{{{
/startattack
/stopmacro [exists,harm,nodead]
/assist [bar:1] Toon1; [bar:3] Toon3
}}}

Now Toon2 will attack Toon1's target, unless he already has a living, hostile target of his own (sticky
targeting). To switch roles and make Toon2 the main just hit the key to switch to actionbar page 2.

The macros for the other ActionBarTargeting buttons work along similar lines. To see the generated code for all
buttons use the command `/abt print` in game.

== Advantages ==

The original idea for a targeting system based on actionbar pages was proposed by Maqz
[http://www.dual-boxing.com/forums/index.php?page=Thread&threadID=4605&s=738cc98ae8e3b100b9f71057105c44a1e43497f1 here].
The advantages are:

    * Focus-free targeting and follow.
    * Works fine in battlegrounds, even if your toons wind up in different groups.
    * One-button selection of main, even in combat, using actionbar page keybinds.

To the best of my knowledge only a few multiboxers have adopted his system though, probably because the macros and bar
setup required are pretty complex. This only gets worse if you are trying to manage more than one team, which is what
led me to an automated approach. With this addon the only extra manual step over a focus-based system is defining your
teams with MultiboxRoster, and that's like 30 sec with a text editor.

== Limitations ==

    * Won't work well if you use action bar pages for another purpose, for instance if you use separate melee and ranged attack bars on a hunter.
    * Macros are not easily customizable. If you're not happy with mine your only recourse is to edit the definitions in `ActionBarTargeting.lua`. I know this sucks -- I'm working on something better.
    * Max of 6 possible mains since that is the max number of possible action bar pages.

== Setup ==

    # Install the companion addon MultiboxRoster and follow the instructions to define your team(s)
    # For each of your offensive spells, create a macro that starts with `\click SetOffensiveTarget`
    # For each of your healing spells, create a macro that starts with `\click SetHealingTarget`
    # Bind keys to actionbar pages 1-5. (I use F1-F5.)
    # Bind a key to `FollowMain`. (WoW keybindings menu)
    # Bind a key to `TargetMainTarget` if you want. (Helpful as an override to sticky targeting.)
    
That's it!

[https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=FJVUV4S9GXX9U&lc=US&item_name=wow5box&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted https://www.paypal.com/en_US/i/btn/btn_donateCC_LG.gif]