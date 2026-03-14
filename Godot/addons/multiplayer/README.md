Note: This hasn't been fully tested and should be considered WIP.

This plugin allows for an easy implementation of P2P Multiplayer functionality, where one player is the host/server. 

TO USE:

1. Drop the parent "addons" folder containing multiplayer directly into a Godot projects "res" folder. Enable the "Multiplayer" plugin.
2. Attach or extend "level.gd" to each level, add all levels uids to the exported "levels" array in the "Game" scene.
3. Create a spawn point scene using a Node3D and attaching "spawn_point.gd", place them around each level.
4. Create a player using a CharacterBody3D, paste its uid into "Game"s exported "player_scene".
5. Adjust "UI", scripts that extend "Level", and "_spawn_point()" inside "game.gd" as needed.

I recommend NOT editing or changing the following:
- multiplayer.gd
- level.gd (though I recommend extending it when level-specific code is needed)
- game.gd (bar the _spawn_function, which should be customized)
- spawn_point.gd
- Game.tscn
