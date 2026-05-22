Consider this a replacement of Godot/addons/multiplayer. 

This provides a Peer-to-Peer connection where one player is a host and the rest connect to them. Granted, this hasn't been tested outside a LAN network.

To use:
1. Make "Multiplayer.tscn" the main scene. I recommend not messing with it or "multiplayer.gd", but feel free to look.
2. Add "level.gd" or extend "Level" to any levels made. Be cautious about the "_ready" function when extending.
3. Create a custom SpawnPoint scene, attaching and customizing "spawn_point.gd" to your needs. Place them around your Levels ("level.gd" handles finding them).
4. Create your own Player scene. This may require making a custom spawn function for "Multiplayer/Player Spawner".
5. Add the Player and every Level scene's UID to the respective exported variable on "Multiplayer.tscn".
6. Deal with the UI scenes visibility once ingame, it won't disappear by default.
