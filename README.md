# ShutEye ![Image of ShutEyes icon](https://dougbarry.github.io/ShutEye-MenuBar-IconOnly.png)

### What is ShutEye?
A Mac .app  .app for controlling your Macs sleep pattern, so it gels with your own.

![Image of ShutEye inactive](https://dougbarry.github.io/ShutEye-MenuBar-Inactive.png)

### What does it do?
Provides an unintrusive MenuBar item which allows use of predefined or custom sleep timers (1 minute, 5 minutes etc). When the timer is reached, the Mac will have it's audio output muted, and sleep.

![Image of ShutEye context menu](https://dougbarry.github.io/ShutEye-MenuBar-Context.png)

### Why does this exist?
You may find this useful, if like me you like to pop something on you Mac, playing while you watch from bed. I know I'll be falling asleep within the hour, so I set 1 hour as the sleep timer on ShutEye, so the Mac isn't on all night producing light and sound (and using power). It also has a tooltip and menu bar text entry to hint at how long till the sleep mode will kick in.

![Image of ShutEye in action](https://dougbarry.github.io/ShutEye-MenuBar-Icon.png)

### Whats needed?
* Prefences of some sort
  * Audio mute on sleep (yes/no)
  * Start with system
  * Different MenuBar icons
  * Proper .App icon
* Tidying up for XCode 8+
* Testing beyond just the Author

### Things of note
* The authod has been using this personally for about 4 years and only just got around to tidying it up and open sourcing it. It was originally written with XCode 3, but things have moved on and this could do with updating to use non-deprecated methods.
* This project was partly for the author to learn a little about how Objective-C in the Mac ecosphere works. He does not profess to be any good at it.
* To the best of the authors knowledge, this does not interfere with [PowerNap](https://support.apple.com/en-gb/HT204032).
* It subscribes to system sleep and wake events and tries to avoid confusing matters if other events cause the system to sleep.
