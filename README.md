# FRONTIER DROP

An original, mobile-first 3D battle-royale prototype built with Godot 4.x.

## Current status
This repository contains a first playable prototype foundation: a procedural low-poly island arena, third-person movement/camera, hitscan shooting, health, practice bots, mobile UI buttons, reload/jump, and a shrinking-zone damage mechanic. It is **not a finished online multiplayer game**. Networking, matchmaking, server-authoritative combat, production-quality character assets/animations, Android export setup, and device testing remain future milestones.

## Run it
1. Install Godot 4.x. Android editor: https://godotengine.org/download/android/
2. Download this repository as ZIP and extract it, or clone it on a computer.
3. In Godot, import the folder containing `project.godot` and run the main scene.

## Controls
- Desktop: WASD move, mouse look, left click fire, R reload, Space jump, Esc releases mouse capture.
- Touch: on-screen directional buttons, FIRE, RELOAD, and JUMP.

## Milestones
- [x] Godot project scaffold
- [x] Procedural arena and simple cover/buildings/trees
- [x] Third-person movement, shooting, health, ammo, practice bots
- [x] Basic touch controls and shrinking-zone damage
- [ ] Character animations and original optimized art
- [ ] Multiplayer replication, player spawning and authoritative combat
- [ ] Lobby, matchmaking, disconnect/reconnect and backend deployment
- [ ] Android export configuration, APK build and real-device testing
- [ ] Performance/load tests for 50 simultaneous players

## Free-first policy
Use open-source tools and permissively licensed assets; verify every asset license before redistribution. Hosting and publishing can incur costs, and reliable 50-player servers cannot be guaranteed free. The current prototype has no working online multiplayer yet.
