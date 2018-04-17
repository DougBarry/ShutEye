#ShutEye

### What is ShutEye?
A Mac .app  .app for controlling your Macs sleep pattern, so it gels with your own.

### What does it do?
Provides an unintrusive MenuBar item which allows use of predefined or custom sleep timers (1 minute, 5 minutes etc). When the timer is reached, the Mac will have it's audio output muted, and sleep.

### Why does this exist?
You may find this useful, if like me you like to pop something on you Mac, playing while you watch from bed. I know I'll be falling asleep within the hour, so I set 1 hour as the sleep timer on ShutEye, so the Mac isn't on all night producing light and sound (and using power).

### Things of note
I've been using this personally for about 4 years and only just got around to tidying it up and open sourcing it. It was originally written with XCode 3, but things have moved on and this could do with updating to use non-deprecated methods!
This project was partly to learn a little about how Objective-C in the Mac ecosphere works. I do not profess to be any good at it!
To the best of my knowledge, this does not interfere with [PowerNap](https://support.apple.com/en-gb/HT204032).
It subscribes to system sleep and wake events and tries to avoid confusing matters if other events cause the system to sleep.
