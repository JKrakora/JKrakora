To use:

1. Make "multiplayer.gd" an Autoload named "Multiplayer"


====
HOW TO USE, READ CAREFULLY AND TRIPLE CHECK!!!

1: "Make multiplayer.gd" an Autoload named "Multiplayer" (Case-sensitive)
	1.5: Set _DEFAULT_PORT and _DEFAULT_ADDRESS in "multiplayer.gd"

2: Set "Main.tscn" as the Main Scene

3: Create a level. For its script, give or extend "level.gd".
	3.5: Add the level(s) UID to Main.Levels in the Inspector [its an array btw]

4: Carefully create a custom player using "Basic Player.tscn" as a reference
	4.5: Add the players UID to Main.Player in the Inspector

5: Modify the function "_custom_spawn_function" in "main.gd" to suit your needs

6: Update the UI node in "Main.tscn" as/if needed
