DJPaul's Sort Inventory for [Don't Starve Together](http://dontstarvetogether.com/)
===

Automatically stacks and sorts your inventory into a sensible order.

## Installation
[Download the latest release](https://github.com/paulgibbs/DJPaul-Sort-Inventory/releases) and extract it into `\Steam\SteamApps\common\Don't Starve Together Beta\mods\`, or find it in the Steam Workshop.

## Usage
Press the `g` key to sort your inventory.

## How does it work?
When you sort your inventory, the mod looks at every item you have, and decides what kind of thing it is. For example, is it a weapon, is it a tool, is it food, and so on. Similar items are then sorted into groups and ordered, where possible, by some relevant value for that group (e.g. weapons are sorted by damage, tools sorted by durability, and food is sorted by how much it feeds or heals you).

The item groups themselves are then sorted into an optimum order determined by playtesting. Finally, each item is then re-inserted into your inventory in its new position. Where possible, items are stacked together to save space.

## Release History
#### v1.8 04/June/2017
- Fix: I made an error packaging v1.7. Oops! Now fixed.

#### v1.7 04/June/2017
- Fix: Crash when sorting stackable equippables (i.e. darts); props @myxal -- many thanks!

#### v1.6 22/October/2016
- Fix: Sort the Mining Lantern into the Lights group.
- Fix: Sort Pitchfork into the Tools group (was Weapons).

#### v1.5 29/January/2016
- New: Add "Fun Mode" (disable/enable to sort key sound effect).
- Fix: Don't handle sort key press when in chat, props ShineSong.

#### v1.4 09/June/2015
- New: Add Nitre to Resources category.

#### v1.3 31/May/2015
- New: When sorting, where possible, items are now stacked together to save space.

#### v1.2 22/May/2015
- Fix: Prevent backpacks being overfilled (the items were being dropped to the floor).
- New: Connecting to a server running this mod will now download the mod if you do not already have it.

#### v1.1 18/May/2015
- Fix: Crash when trying to sort inventory in main menu.
- New: Added mod logo.

#### v1.0 17/May/2015
- First release!
- New: Rocks are sorted into the resources category.

#### v1.0-rc-1 16/May/2015
- New: Backpack support.
- New: Setting to control what kind of items are sorted into your backpack.
- New: Setting to change the keybind for the sort key (defaults to "g").
- New: More item categories (resources, armour).
- Fix: Misc. code improvements.

#### v1.0-beta-3 07/May/2015
- New: Mod option to set the maximum number of torches sorted.
- New: Don't sort anything if the player is a ghost.
- Fix: Now works on game clients. :)
- Fix: Minor misc. code improvements.

#### v1.0-beta-2 04/May/2015
- New: Gears are sorted with other food.
- New: Foods are sorted by their health bonus (instead of hunger) if player is seriously injured.
- Fix: Code has been tidied up.
- Fix: Manylots improvements to inventory sorting logic.
- Fix: Tools are always sorted before Weapons.

#### v1.0-beta-1 03/May/2015
- Initial release for private testing.

## Legal
Copyright © 2015, Paul Gibbs.

Licensed under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

Find this mod on Github at https://github.com/paulgibbs/DJPaul-Sort-Inventory
