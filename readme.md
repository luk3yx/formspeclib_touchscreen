# Formspeclib Touchscreen

License:
* Code - LGPL v3 or later (contains some code from digistuff)

Dependencies:
* Required: formspeclib, digilines
* Only needed for craft recipes: digistuff, default

## Crafting
The crafting recipe for the formspeclib touchscreen is shapeless, and only requires one digistuff touchscreen plus a diamond.

## Usage
This mod receives signals through digilines, much like digistuff touchscreens. The examples below assume you're using luacontrollers to send the digiline signals.

These are the commands:
* `digiline_send(channel, {command = "clear"})` - Manually clears the formspec.
* `digiline_send(channel, {command = "lock"})` - Locks the touchscreen to protection.
* `digiline_send(channel, {command = "unlock"})` - Unlocks the touchscreen.

The system for adding GUI elements is based on [formspeclib](https://github.com/luk3yx/formspeclib) - if you want more information, look there.

You can add elements in one of two ways:
* `digiline_send(channel, {type = ..., x = ..., y = ..., ...})` adds a new, singular GUI element to the screen. Parameters vary according to formspeclib's specifications.
* `digiline_send(channel, {width = ..., height = ..., {type = ..., ...}, {type = ..., ...}, ...})` replaces the formspec with an entirely new one with the dimensions and elements specified.

The `append` parameter may be added to either one of these two in order to modify the behavior of the message. If you add `append = true` to the table, even if you specify multiple elements or new dimensions, the formspec won't be replaced.

Receiving signals from player interaction with the GUI elements works in the same way as it does with digistuff touchscreens. Button `name` parameters work in the same way as they do in the digistuff mod.
