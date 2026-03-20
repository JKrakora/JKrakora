Consider this a replacement of Godot/addons/multiplayer. 

This provides a Peer-to-Peer connection where one player is a host and the rest connect to them. 

To use:
1. Make "Multiplayer.tscn" the main scene.
2. Add "level.gd" or extend "Level" to any levels made. Be cautious about the "_ready" function when extending.
3. Create a custom SpawnPoint scene, attaching and customizing "spawn_point.gd" to your needs. Place them around your Levels.
4. Create your own Player scene. 
5. Add the Player and every Level scene's UID to the respective exported variables of "Multiplayer.tscn".
6. Deal with the UI scenes visibility once ingame, it won't disappear by default. 

Generally: 
- Don't edit "Multiplayer.tscn" or "multiplayer.gd", but please look.
- "level.gd" should be extended, not edited.
- "spawn_point" can be edited, but please know what it does first.
- Do what you want with "UI.tscn" and "UI.gd", but be careful refactoring it. 
That's pretty much it. 
