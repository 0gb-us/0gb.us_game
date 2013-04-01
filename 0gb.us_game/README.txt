 ###   ###  ####        #   #  ####        ###   ###   ###   ###   ### 
#   # #   # #   #       #   # #      ###  #   # #   # #   # #   # #   #
#  ## #     #   #       #   # #      ###      # #  ## #  ## #  ## #  ##
# # # #     ####        #   #  ###          ##  # # # # # # # # # # # #
##  # #  ## #   #       #   #     #  ###      # ##  # ##  # ##  # ##  #
#   # #   # #   #  ###  #   #     #  ###  #   # #   # #   # #   # #   #
 ###   ###  ####   ###   ###  ####         ###   ###   ###   ###   ### 

  --==--  What is this?  --==--

If you don't know what Minetest is, a good place to find out about it would be http://minetest.net/.

  --==--  License:  --==--

Code: GNU Lesser General Public License
Media: Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

Anything added to this game must be compatible with those licenses.

The stuff in the minetest_game directory:
Copyright (C) 2010-2012 celeron55, Perttu Ahola <celeron55@gmail.com>

The stuff in the added directory:
Copyright (C) 2012-2013 0gb.us, Richard Palmer <0gb.us@0gb.us>

  --==--  0gb.us_game  --==--  

This is the game directory used on the 0gb.us:30000 server. It is not meant to be the perfect game. There are so many things I would love to see in Minetest, but most of them will not be implemented here. This game's goal is to provide an environment where users hold enough power that administrators and moderators are not necessary, while not deviating from minetest_game too much. Specifically, no new nodes may be defined, now alterations to the number of each node available may be modified, and any entities defined must have little effect on the game itself as well as have a built-in self-destruct mechanism, to prevent most of them from being saved to the SQLite file. As of Minetest 0.4.6, all nodes must be defined in common, but in rare cases, may be redefined.

Some administrative tools ARE included. While the goal involves setting things up to not REQUIRE a staff, as staff does tend to make things better. Any administrative tools defined must not give the staff new capabilities. Rather, these tools provide a faster way to do what they could have already been able to do without said tools.

As stated above, this is the game used at 0gb.us:30000. I reserve the right to decline any changes to it for any or no reason. If you want to help add features or fix bug, your help is greatly appreciated, but I have a very specific vision for what I want this game to be. Please don't be offended if I decline a pull request, especially if it makes huge changes.

  --==-- Usability fixes:  --==--  

Usability fixes may also be added to this game, provided they adhere to the basic rules imposed by this game's development. In addition, the following plugins from minetest_game are not included:

* wool and dye: These two shouldn't even be in minetest_game anyway, as there is no way to obtain them. New players type "/mods", see wool, and say "Wool is installed. How do I get it?". All these two do by default is cause confusion.
* creative: While it makes sense to have creative in minetest_game, there was no point in including it on my non-creative server.

  --==-- Notes on Windows:  --==--

While initially, I tried not to break compatibility with Windows, eventually, it proved to be too difficult. In all it's stupidity, Windows is case-insensitive. There is no non-hacky way around this. In Minetest, "Foo", "FOO" and "foo" are three different users. When each needs a file to store data in and there are an arbitrary number of users, the obvious answer, as two users cannot share a name, is to use the user's name as their file name. But Windows is pathetic, and (among other problems) mistakingly thinks that "Foo", "FOO" and "foo" are are the same file name. I came up with a hacky workaround that worked in Windows, but I ended up removing it. It was too hacky, and I don't want to have ugly code to try to maintain.

Therefore, know that this game is not Windows-compatible. Until Microsoft decides to make an operating system that actually functions correctly, I'll be focusing only on Linux (and whatever other operating systems Minetest is ported to), as it actually does things right. Any plugin that doesn't work in Windows should have an abort line at the top, disabling the plugin when used on a case-insensitive file system. If you add anything new to this game, please follow that convention. If you are a Windows user and you remove that line from your copy, know that you will likely mess up your data, and it will be your own fault, both for choosing to use the worlds most pathetic excuse for an operating system and for removing the failsafe. You have been warned. If you leave the failsafes in place, some functionality will be disabled, but you data shouldn't be corrupted by this game.

  --==--  To do:  --==--  

* Rewrite whisper: The whisper plugin on the forum has many issues. I'm going to rewrite something similar from scratch, but make it actually function correctly.
* Build a crafting guide: Um. Yeah. This may take time. If you plan to take this on, know that any solution that generates actual stacks of items (even if they theoretically cannot be moved to the main inventory) will not be accepted. The crafting guide will be implemented as a page in the menu, not as a node with a formspec.

  --==--  Not to do:  --==--  
* There are currently no plans for public bookmarking (unless it can be fully managed without staff intervention AND can be disabled via minetest.conf).
* There are no plans to make the number of points gotten from mining visible to the user (unless there is a way to disable it from minetest.conf (WILL be disabled at 0gb.us:30000)).
* There are no plans to add node renewability (such as papyrus/cactus/junglegrass/dry shrub growth or water + lava == stone). While I sorely want renewability, I think it belongs in common, and I'm waiting for things to be renewable there, then I'll migrate it here.
* Shared locked chests without shared locked doors. If shared chests are to be added to this game, shared doors must also be added.

  --==--  Notes on settings:  --==--  

Any type of configurations and settings must be made to work using minetest.conf when possible. When not possible (or not feasible), these things must at least be done from outside the 0gb.us_game directory. Including configuration files within the plugin directories themselves is not in any way acceptable. This makes world-specific configuration impossible with worlds sharing a plugin without having multiple copies of said plugin. If Lua is somehow needed in configuration files (and it almost always IS NOT), this can be done from the world directory, not the plugin directory. Not only that, there must always be some sort of fallback for when the configuration file is not present. In building a way to fall back to a default, you'll usually see it is much easier to read settings from minetet.conf than to write a configuration Lua script with a way to fall back if it is missing.

