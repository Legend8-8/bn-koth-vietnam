# Maps Folder

Put map-specific mission overrides in one folder per map:

- maps/cam_lao_nam/
- maps/khe_sanh/
- maps/bra/
- maps/altis/

Typical per-map files:

- mission.sqm
- config/locations.hpp
- optional map-only assets or scripts

Tooling behavior:

- setup_dev_environment.py creates one linked mission folder per map using <MISSION_STEM>.<map_name>
- build.py exports one build_output mission folder per map
- shared root files are linked/copied after map files, so map-specific files win for name collisions

Important:

- If a map folder is missing mission.sqm, that generated mission folder will not be playable yet.
- Put map-specific zone config in maps/<map_name>/config/locations.hpp.
