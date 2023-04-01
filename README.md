## Preview

- 

## Resmon

<p> Start up: ~0.12/ms</p>
<p> In use: ~0.01/ms</p>
<p> Idle: 0.00/ms</p>

## What is this?

<p>This is a standalone all in one player owned gas station script with a few dependencies to make sure everything runs</p>

<p>It's made to be an install and forget about it script where admins can set gas station owners with many options</p>

This resource includes:

- Admin menu to assign owners and check stats
- Owner menu to look at gas station stats
- Owners can withdraw cash from sold fuel
- Job where owners can purchase more fuel and complete the delivery
- Car lose fuel like any fuel script
- Animation and props from refueling 
- Database uploads on a timer

## What do I need?

<p>There are 4 dependencies needed to make sure the script runs , make sure you have the most recent releases:</p>
<p>- <a href='https://github.com/overextended/ox_inventory/'>Ox Inventory</a></p>
<p>- <a href='https://github.com/overextended/ox_lib/releases/'>Ox Lib</a></p>
<p>- <a href='https://github.com/overextended/ox_target/'>Ox Target</a></p>
<p>- <a href='https://github.com/overextended/oxmysql'>Ox MySQL</a></p>

## Installation

- Install all dependencies and make sure they run
- Upload dom_fuel SQL into your database
- Setup permissions in your server cfg to use the admin menu
```lua
add_ace group.admin admingasstationmenu allow
```
- Start dom_fuel AFTER all dependencies


## Need Support?
<a href='https://discord.gg/GH4fdmMG5b'>Discord</a>
