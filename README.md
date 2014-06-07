Audiobook-Player
================

Final project for CS 193p

## Features 
- "Open in" functionality to import audio files from other apps
- Background audio
- Supports iTunes file sharing - transfer audiobooks to AP with iTunes
- Custom colorful UITableViewCells that display current progress in audiobook
- Swipe in different directions to skip different amounts
- Tap to play/pause
- Custom UISlider to seek at different rates
- Tracks save position
- Can play audio via AirPlay
- Play and pause and switch audio files through Control Center
- Login via Facebook or anonymously
- Download and play audio files from the Internet
- Choose between light and dark themes

## SDK Breadth
- AVAudioPlayer
- Attributed strings
- Airplay
- Tap gestures
- Customized pan gestures
- Swipe gestures
- "Open in" functionality
- Control center integration
- Subclassed UITableViewCells
- File directory browsing with NSFileManager
- Side panels
- Settings stored in NSUserDefaults
- UIAlertView 
- Parse integration
- Background audio
- Subclassed UIWebView
- Modified SVWebViewController to allow access to _shouldStartLoadWithRequest_ delegate method.
- Asynchronous file downloading
- Push notifications
- Landscape orientation supported with AutoLayout
- NSTimers for automatically updating custom UITableViewCells and UISliders
- MPVolumeView to control volume and synchronize it with the system volume

Collaboration:
Collaborated with Sherwin Yuyang Xia, a design student. He was very helpful, providing ideas and prototypes. You can check out his prototype here:
https://www.fluidui.com/editor/live/preview/p_aeg8t3w9BdN6cQ3NxqFmM3QkwxPMqZhB.1401104878677

Additionally, you can see all of the layouts he created here:
https://www.dropbox.com/s/o9z94up5yaozc14/alllayouts.png




	Features:
		- Open audio files gotten through other applications (register itself as an audio player with the system, so other applications can choose this application as an "Open in..." option for audio files)
		- Position in each audio file will be saved
		- Swipe gestures to skip forward and back in the audio file. 
		- Tap gesture to pause/play audio
		- Browse files and allow for creation of new folders and moving files between folders

	Possible extra features:
		- Browse the internet using a built-in UIWebView to download audio files
		- Sleep timer (stop playing audio after a specified period of time)
		- Customize gestures
		- Light/dark theme

What parts of iOS will it use?
	- UIWebView to browse internet
	- Core Data (???) to store downloaded audio files 
	- Core Data to store last-played positions in audio files
	- Core Audio to play audio files
	- Gesture recognizers to recognize gestures
	- UITableViews to display file directories
	- NSTimer for sleep timer
	- Backgrounding to play audio in the background