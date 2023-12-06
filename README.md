# Personal mpv Configuration for Windows

<p align="center"><img width=100% src="https://github.com/handy1928/mpv-config/blob/main/screenshots/showcase_1.webp" alt="mpv screenshot"></p>
<p align="center"><img width=100% src="https://github.com/handy1928/mpv-config/blob/main/screenshots/showcase_2.webp" alt="mpv screenshot"></p>
<p align="center"><img width=100% src="https://github.com/handy1928/mpv-config/blob/main/screenshots/showcase_3.webp" alt="mpv screenshot"></p>
<p align="center"><img width=100% src="https://github.com/handy1928/mpv-config/blob/main/screenshots/showcase_4.webp" alt="mpv screenshot"></p>

## Overview
Just my personal config files for use in [mpv,](https://mpv.io/) a free, open-source, & cross-platform media player, with a focus on quality and a practical yet comfortable viewing experience. Contains tuned profiles (for up/downscaling, live action & anime), custom key bindings, a GUI, as well as multiple scripts, shaders & filters serving different functions. Suitable for both high and low-end computers (with some tweaks).

## Scripts
- [uosc](https://github.com/darsain/uosc) - Adds a minimalist but highly customizable gui.
- [thumbfast](https://github.com/po5/thumbfast) - High-performance on-the-fly thumbnailer.
- [memo](https://github.com/po5/memo) - Saves watch history, and displays it in a nice menu, integrated with uosc. 
- [sview](https://github.com/he2a/mpv-scripts/blob/main/scripts/sview.lua) - Show shaders currently running, triggered on shader activation or by toggle button.
- [autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua) - Automatically load playlist entries before and after the currently playing file, by scanning the directory.
- [autodeint](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autodeint.lua) - Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by toggle button.
- [misc](https://github.com/stax76/mpv-scripts/blob/main/misc.lua)
  - Show detailed media info on screen.
  - Restart mpv restoring the properties path, time-pos, pause and volume.
  - Execute Lua code from input.conf.
  - When seeking display position and duration like so: 70:00 / 80:00.
- [user-input](https://github.com/CogentRedTester/mpv-user-input) - common API that other scripts can use to request text input from the user via the OSD.
- [rename](https://github.com/Kayizoku/mpv-rename) - Ability to rename files on the go directly within MPV player window without having to leave it.
- [copy-time](https://github.com/linguisticmind/mpv-scripts/blob/master/copy-time/win/copy-time.lua) - Copies current timecode in HH:MM:SS.MS format to clipboard (Windows).
- [show-errors](https://github.com/CogentRedTester/mpv-scripts/blob/master/show-errors.lua) - Prints error messages onto the OSD.
- [crop](https://github.com/occivink/mpv-scripts/blob/master/scripts/crop.lua) - Crop the current video in a visual manner.
- [M_x](https://github.com/Seme4eg/mpv-scripts/tree/master#m-x) - A menu that shows all commands you have available, key bindings and commends (if present) and from which you can call any of those commands.
- ~~[taskbar-buttons](https://github.com/qwerty12/mpv-taskbar-buttons/tree/pure-luajit) - Hack to add media control taskbar buttons (well, thumbbar buttons) for mpv.~~
- [clipboard](https://github.com/CogentRedTester/mpv-clipboard) - Provides generic but powerful low-level clipboard commands for users and script writers.
- [visualizer](https://github.com/mfcc64/mpv-scripts/blob/master/visualizer.lua) - various audio visualization.
- [waveform](https://github.com/MikelSotomonte/mpv-waveform/tree/main) - Displays a waveform of the video in real-time using ffmpeg waveforms.
- [chapterskip](https://github.com/po5/chapterskip) - Automatically skips chapters based on title.
- - -
Personally added in scripts:

* Show all Tracks (Video, Audio, Subtitles) in one uosc menu.
* Added Bitrate shown in Track view loaded via MediaInfo. ([MediaInfo CLI](https://mediaarea.net/en/MediaInfo/Download/Windows) has to be installed)
* Added ability to sort by key length in M-x keybind menu.
* Script to calculate the diffrence between 2 times and copy to clipboard. (my workflow: 2 mpv windows open Ctrl+c in 1 to copy the time. Ctrl+v in 2 to get the diffrence of both times in clipboard)
* Every Keybind is in the uosc Menu
* Ability to disable creating thumbnails
* Abitlity to scroll on Buttons. For example to cycle audio and subtitle tracks.

## Shaders
- [nlmeans](https://github.com/AN3223/dotfiles/tree/master/.config/mpv/shaders) - Highly configurable and featureful denoiser.
- [NVIDIA Image Sharpening](https://gist.github.com/agyild/7e8951915b2bf24526a9343d951db214) - An adaptive-directional sharpening algorithm shaders.
- [FidelityFX CAS](https://gist.github.com/agyild/bbb4e58298b2f86aa24da3032a0d2ee6) - Sharpening shader that provides an even level of sharpness across the frame. 
- [FSRCNNX-TensorFlow](https://github.com/igv/FSRCNN-TensorFlow) - Very resource intensive upscaler that uses a neural network to upscale accurately.
- [Anime4k](https://github.com/bloc97/Anime4K) - Shaders designed to scale and enhance anime. Includes shaders for line sharpening, artefact removal, denoising, upscaling, and more.
- [AMD FidelityFX Super Resolution](https://gist.github.com/agyild/82219c545228d70c5604f865ce0b0ce5) - A spatial upscaler which provides consistent upscaling quality regardless of whether the frame is in movement.
- [mpv-prescalers](https://github.com/bjin/mpv-prescalers) - RAVU (Rapid and Accurate Video Upscaling) is a set of prescalers with an overall performance consumption design slightly higher than the built-in ewa scaler, while providing much better results. 
- [SSimDownscaler, SSimSuperRes, KrigBilateral, Adaptive Sharpen](https://gist.github.com/igv)
    - Adaptive Sharpen: Another sharpening shader.
    - SSimDownscaler: Perceptually based downscaler.
    - KrigBilateral: Chroma scaler that uses luma information for high quality upscaling.
    - SSimSuperRes: Make corrections to the image upscaled by mpv built-in scaler (removes ringing artifacts and restores original  sharpness).
   
## Installation (on Windows)

(Not tested on Linux and macOS. For Linux and macOS users, once mpv is installed, copying the contents of my GitHub into a `portable_config` inside the [relevant](https://mpv.io/manual/master/#files) folders should be sufficient.)

* Download the latest 64bit (or 64bit-v3 for newer CPUs) mpv Windows build by shinchiro [here](https://mpv.io/installation/) or directly from [here](https://sourceforge.net/projects/mpv-player-windows/files/) and extract its contents into a folder of your choice (mine is called mpv). This is now your mpv folder and can be placed wherever you want.
* Run `mpv-install.bat`, which is located in the `installer` folder (see below), with administrator privileges by right-clicking and selecting run as administrator, after it's done, you'll get a prompt to open Control Panel and set mpv as the default player.
* Download and extract the [GitHub ZIP](https://github.com/handy1928/mpv-config/archive/refs/heads/main.zip) into a folder called `portable_config` inside the mpv folder you just made.
* **Adjust any settings in [mpv.conf](https://github.com/handy1928/mpv/blob/main/mpv.conf) to fit your system, use the [manual](https://mpv.io/manual/master/) to find out what different options do or open an issue if you need any help.**
* You are good to go. Go watch some videos!

After following the steps above, your mpv folder should have the following structure:

## File Structure (on Windows)

```
mpv
|
├── doc
│   ├── manual.pdf
│   └── mpbindings.png                    # Default key bindings if not overridden in input.conf
│
├── installer
│   ├── configure-opengl-hq.bat
│   ├── mpv-icon.ico
│   ├── mpv-install.bat                   # Run with administrator priviledges to install mpv
│   ├── mpv-uninstall.bat                 # Run with administrator priviledges to uninstall mpv
│   └── updater.ps1
│
├── portable_config                       # This is where my config is placed
│   ├── cache                             # Created automatically   
│   │
│   ├── fonts
│   │   ├── ClearSans-Bold.ttf
│   │   ├── JetBrainsMono-Regular.ttf
│   │   ├── MotivaSans-Bold.ttf
|   |   ├── uosc-icons.otf
|   |   └── uosc-textures.ttf
│   │
│   ├── screenshots
|   |   ├── showcase_1.webp
|   |   ├── showcase_2.webp
|   |   ├── showcase_3.webp
|   |   └── showcase_4.webp
│   │
│   ├── script-modules
│   │   ├── extended-menu.lua
│   │   └── user-input-module.lua
│   │
│   ├── script-opts                       # Contains configuration files for scripts
|   |   ├── console.conf
|   |   ├── crop.conf
|   |   ├── M_x.conf
|   |   ├── memo.conf
|   |   ├── memo-history.log              # Created automatically
│   │   ├── show_errors.conf
│   │   ├── thumbfast.conf
│   │   └── uosc.conf                     # Set desired default directory for uosc menu here
│   │
│   ├── scripts
│   │   ├── uosc
│   │       ├── elements
|   |           ├── BufferingIndicator.lua
|   |           ├── Button.lua
|   |           ├── Controls.lua
|   |           ├── Curtain.lua
|   |           ├── CycleButton.lua
|   |           ├── Element.lua
|   |           ├── Elements.lua
|   |           ├── Menu.lua
|   |           ├── PauseIndicator.lua
|   |           ├── Speed.lua
|   |           ├── Timeline.lua
|   |           ├── TopBar.lua
|   |           ├── Volume.lua
|   |           └── WindowBorder.lua
|   |       ├── intl
|   |           ├── de.lua
|   |           ├── es.lua
|   |           ├── fr.lua
|   |           ├── ro.lua
|   |           └── zh-hans.lua
|   |       ├── lib
|   |           ├── ass.lua
|   |           ├── intl.lua
|   |           ├── mediainfo.lua
|   |           ├── menus.lua
|   |           ├── std.lua
|   |           ├── text.lua
|   |           └── utils.lua
|   |       └── main.lua
│   │
│   │   ├── autodeint.lua                 # Set key binding here, not input.conf (Ctrl+d)
│   │   ├── autoload.lua
│   │   ├── clipboard.lua
│   │   ├── copy-time.lua
|   |   ├── crop.lua
|   |   ├── M-x.lua
|   |   ├── memo.lua
|   |   ├── misc.lua
|   |   ├── Rename.lua
|   |   ├── show-errors.lua
|   |   ├── sview.lua
│   │   ├── thumbfast.lua
│   │   ├── user-input.lua
│   │   ├── visualizer.lua
│   │   └── waveform.lua
│   │
│   ├── shaders                           # Contains external shaders
│   │   ├── myOldShaders                  # TODO sort out
│   │   ├── A4K_Dark.glsl
│   │   ├── A4K_Thin.glsl
│   │   ├── A4K_Upscale_L.glsl
│   │   ├── adasharp.glsl
│   │   ├── adasharpA.glsl                # Adjusted for anime
│   │   ├── CAS.glsl
│   │   ├── F8.glsl
│   │   ├── F8_LA.glsl
│   │   ├── FSR.glsl
│   │   ├── krigbl.glsl
│   │   ├── nlmeans_hqx.glsl
│   │   ├── NVSharpen.glsl
│   │   ├── ravu_L_r4.hook
│   │   ├── ravu_Z_r3.hook
│   │   ├── ssimds.glsl
│   │   └── ssimsr.glsl
│   │
|   ├── watch_later                       # Video timestamps saved here (created automatically)
|   ├── fonts.conf                        # Delete duplicate when installing in steps above
│   ├── input.conf                        # Tweak uosc right click menu here
│   ├── mpv.conf                          # General anime profile here
|   └── profiles.conf                     # Up/downscale and more anime profiles here
|
├── .gitignore
├── d3dcompiler_43.dll
├── mpv.com
├── mpv.exe                               # The mpv executable file
├── README.md
└── updater.bat                           # Run with administrator priviledges to update mpv
```

## Key Bindings
Custom key bindings can be added/edited in the [input.conf](https://github.com/handy1928/mpv/blob/main/input.conf) file. Refer to the [manual](https://mpv.io/manual/master/) and [uosc](https://github.com/tomasklaen/uosc#commands) commands for making any changes. Default key bindings can be seen from the [input.conf](https://github.com/handy1928/mpv/blob/main/input.conf) file but most of the player functions can be used through the menu accessed by `Right Click` and the buttons above the timeline as seen in the image above.

## Useful Links

* [mpv wiki](https://github.com/mpv-player/mpv/wiki) - Official wiki with links to user scripts, FAQ's and much more.
* [Mathematical evaluation of various scalers](https://artoriuz.github.io/blog/mpv_upscaling.html) - My config uses the best scalers/settings from this analysis.
* [mpv manual](https://mpv.io/manual/master/) - Lists all the settings and configuration options available including video/audio filters, scripting, and countless other customizations.
* [watch-later-options](https://github.com/mpv-player/mpv/blob/master/options/options.c) - Code in mpv where all watch-later-options are stored. Used to remove the ones i don't want to save.
* [Denoise Shaders](https://github.com/AN3223/dotfiles/tree/master/.config/mpv/shaders) - Collection of Shaders to denoise

Thank you very much to [@Zabooby](https://github.com/Zabooby). This config is forked from [here](https://github.com/Zabooby/mpv-config). I edited and added a lot to fit my needs.