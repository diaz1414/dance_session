# 🎶 Dance Session System

**Author:** DIAZ  
**Framework:** QBCore/ESX/Standalone  
**Menu:** ox_lib  
**Notification:** Choose between QBCore, ESX, or ox_lib (see `config.lua`)

## Description
This script allows players to create synchronized dance sessions:  
- The host creates a session and selects a dance.  
- Players can join and follow the host’s animation.  
- Stop dance, leave session, or end session.  
- Auto-kick members when they disconnect, and auto-end if the host disconnects.

## Features
- `/createsession` → Create a new session  
- `/opendance` → Host chooses dance (ox_lib menu)  
- `/joindance [id]` → Join an existing session  
- `/leavedance` → Leave the session  
- `/stopdance` → Stop dance (host stops for all, members stop their own)  
- `/endsession` → Host ends the session  
- Flexible notification system (QBCore / ESX / ox_lib)  
- Auto-kick on disconnect  

## Installation
1. Place the `dance_session` folder into `resources/[local]`  
2. Make sure the following dependencies are installed:  
   - `ox_lib`  
   - `dpemote`  
   - QBCore / ESX (optional, depending on your config)  
3. Add the following lines to your `server.cfg`:
```cfg
ensure ox_lib
ensure dpemote
ensure dance_session
