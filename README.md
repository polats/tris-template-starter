# Star Catcher

A small Godot 4 game to start from on [Tris](https://creds.club). Catch the falling stars: move
with the arrow keys, the mouse or a finger.

The whole game is `main.gd`. It draws everything in code, so there are no art files to manage.
Change it, push, and Tris builds the web version and updates your play link.

## Run it locally

Open the folder in Godot 4.3 or later and press Play.

## What Tris needs

- `project.godot` names the Godot version in `config/features`.
- `export_presets.cfg` has a Web preset. The renderer is Compatibility, the only one browsers run.
- GDScript only: Godot 4 cannot export C# projects to the web.
