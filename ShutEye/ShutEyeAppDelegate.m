//
//  ShutEyeAppDelegate.m
//  ShutEye V0.2
//
//  Copyright (c) Douglas Barry 2014-2018
//  First version 20140825.
//  Last update 20180412.
//

#import "ShutEyeAppDelegate.h"
#import "ShutEyeWindowController.h"

@implementation ShutEyeAppDelegate
@synthesize sleepCheckTimer;
@synthesize aboutWindow;

NSStatusItem *statusItem;
NSMenu *theMenu;

bool shutEyeActiveTimeSpanIsCustom = false;
long shutEyeActiveTimeSpan = 0;
NSDate* shuEyeActiveSleepTargetDTS;
bool shutEyeEnabled = false;

#define CUSTOM_TIME_MIN 30
#define CUSTOM_TIME_MAX (3600*48)
#define WAKETIMER_INTERVAL 5

#define DISABLE_ABOUTWINDOW

#define DEFAULT_TOOLTIPTEXT @"Sleep, controlled"

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Startup");
//    NSLocalizedString(@"TEST", nil)];
    
    NSArray *timeSpans = nil;
    
    timeSpans = @[@"1 Hour|3600", @"30 Minutes|1800", @"15 Minutes|600", @"5 Minutes|300", @"1 Minute|60"];
    
    NSMenuItem *tItem = nil;
    
    theMenu = [[NSMenu alloc] initWithTitle:@""];
    
    [theMenu setAutoenablesItems:NO];

#ifndef DISABLE_ABOUTWINDOW
    [theMenu addItemWithTitle:@"About ShutEye" action:@selector(OnSelectAbout:) keyEquivalent:@""];
    tItem = [theMenu itemWithTitle:@"About ShutEye"];
    [tItem setTag:-2];
#endif
    
    for( NSString *timeSpanDesc in timeSpans)
    {
        NSArray *timeSpanParts = [timeSpanDesc componentsSeparatedByString:@"|"];
        if(timeSpanParts.count < 2) continue;
        [theMenu addItemWithTitle:timeSpanParts[0] action:@selector(onSelectTimeSpanStd:) keyEquivalent:@""];
        tItem = [theMenu itemWithTitle:timeSpanParts[0]];
        [tItem setTag:[timeSpanParts[1] integerValue]];
    }
    
    [theMenu addItemWithTitle:@"Now!" action:@selector(onSelectSleepNow:) keyEquivalent:@""];
    [theMenu addItemWithTitle:@"Disabled" action:@selector(onSelectSleepDisable:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]];
    [theMenu addItemWithTitle:@"Custom..." action:@selector(onSelectTimeSpanCustom:) keyEquivalent:@""];
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    tItem = [theMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:(@"MenuBarIcon")]];
    [statusItem setAlternateImage:[NSImage imageNamed:(@"MenuBarIcon")]];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:theMenu];

    // create timer, check every 60 seconds...
    sleepCheckTimer = [NSTimer scheduledTimerWithTimeInterval:WAKETIMER_INTERVAL
                                     target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
    
    [self disableShutEye];
    
    // file for notifications
    NSLog(@"Filing for system sleep/wake notifications");
    [self systemFileForNotifications];
    
}

#ifndef DISABLE_ABOUTWINDOW
-(void)OnSelectAbout:(id) sender
{
    if ([self aboutWindow] == nil){
        aboutWindow = [[ShutEyeWindowController alloc]
                       initWithWindowNibName:@"About ShutEye"];
    }
    
    [[self aboutWindow] showWindow:self];
}
#endif

-(void)onSelectTimeSpanStd:(id) sender
{
    shutEyeEnabled = true;
    NSMenuItem *menuItem = (NSMenuItem *) sender;
    long span = (long)menuItem.tag;
    menuItem = nil;
    [self shutEyeSetTimespan:span isCustom:false];
    [self enableShutEye];
}
     
-(void)onSelectTimeSpanCustom:(id) sender
{
    NSLog(@"Custom time span selected.");
    NSString *input = [self inputBox:@"Enter custom sleep period in seconds:"];
    
    if(input == nil)
    {
        // cancel or bad return!
        NSLog(@"Cancelled or bad return value.");
        [[NSSound soundNamed:@"Basso"] play];
        return;
    }
    
    long customTime = [input intValue];
    input = nil;
    NSLog(@"Timespan: %ld", customTime);
    
    if(customTime <= 0)
    {
        NSLog(@"Custom value is invalid. (<= zero)");
        [[NSSound soundNamed:@"Basso"] play];
        return;
    } else if(customTime <= 60) {
        NSLog(@"Custom value too small, clamping to the minimum: %lds", (long)CUSTOM_TIME_MIN);
        customTime = CUSTOM_TIME_MIN;
    } else if(customTime > (long)CUSTOM_TIME_MAX) {
        NSLog(@"Custom value too large, clamping to the maximum: %lds", (long)CUSTOM_TIME_MAX);
        customTime = CUSTOM_TIME_MAX;
    }
    
    NSLog(@"Custom value used: %ld", customTime);
    
    [self shutEyeSetTimespan:customTime isCustom:true];
    [self enableShutEye];
}

-(void)onSelectSleepNow:(id) sender
{
    [self shutEyeGotoSleep];
}

-(void)onSelectSleepDisable:(id) sender
{
    [self disableShutEye];
}

-(void)onTimerTick:(NSTimer *)timer
{
    //do smth
    NSLog(@"Timer tick");
    [self shutEyeUpdate];
}

-(void)shutEyeUpdate
{
    if(shutEyeActiveTimeSpan < 1) return;
    
    long timeDifference = fabs([shuEyeActiveSleepTargetDTS timeIntervalSinceNow]);
    
    
    NSDate* rightNow = nil;
    rightNow = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    // check if time now is after the requested sleep time
    if([shuEyeActiveSleepTargetDTS compare:rightNow] != NSOrderedAscending)
    {
        // by a little bit...
        if(timeDifference < (WAKETIMER_INTERVAL + 2))
        {
            [self shutEyeGotoSleep];
            return;
        }
    }
    
    rightNow = nil;

    [self shutEyeUpdateUI];
}

-(void)shutEyeSetTimespan:(long) timeSpan isCustom:(bool) timeSpanIsCustom
{
    shutEyeEnabled = true;
    NSLog(@"Timespan selected %ld, Custom: %s", timeSpan, (timeSpanIsCustom ? "true" : "false"));

    shutEyeActiveTimeSpan = timeSpan;
    shutEyeActiveTimeSpanIsCustom = timeSpanIsCustom;
    shuEyeActiveSleepTargetDTS = [[NSDate alloc] initWithTimeIntervalSinceNow:shutEyeActiveTimeSpan];
    NSLog(@"Sleep time target updated: %@", shuEyeActiveSleepTargetDTS);
}

-(NSString *)inputBox: (NSString *)prompt
{
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
//    [[alert window] makeFirstResponder:input];
    
    // mad hacks for delayed dispatch to set input text field focus after modal alert is displayed
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 500);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[alert window] setInitialFirstResponder:input];
        [[alert window] makeFirstResponder:input];
    });

    //    [[alert window] setInitialFirstResponder: input];

    NSInteger button = [alert runModal];
    
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    }
    else if (button == NSAlertAlternateReturn) {
        return nil;
    }
    else {
        return nil;
    }
}

-(NSString*)getFriendlyTimeIntervalString:(long)timeInterval
{
    if(shutEyeEnabled)
    {
        if(timeInterval<60) return [NSString stringWithFormat:@"%lds", timeInterval];
        if(timeInterval<120) return @"<2m";
        if(timeInterval<300) return @"<5m";
        if(timeInterval<600) return @"10m";
        if(timeInterval<900) return @"15m";
        if(timeInterval<1800) return @"30m";
        if(timeInterval<3600) return @"1h";
        if(timeInterval>3600) return @">1h";
    }
    return @"";
}

-(void)shutEyeUpdateUI
{
    if (shutEyeEnabled)
    {
        long timeDifference = fabs([shuEyeActiveSleepTargetDTS timeIntervalSinceNow]);
        NSString *infoText = [NSString stringWithFormat:@"Sleeping in %@", [self getFriendlyTimeIntervalString:timeDifference]];
        [statusItem setToolTip:infoText];
        [statusItem setTitle:[self getFriendlyTimeIntervalString:timeDifference]];
    } else {
        [statusItem setToolTip:DEFAULT_TOOLTIPTEXT];
        [statusItem setTitle:NULL];
    }
}
     
-(void)shutEyeGotoSleep
{
    NSLog(@"Start sleep process");
    [self disableShutEye];
    [self systemMuteOutput];
    [self systemSleepNow];
 }
     
-(void)systemSleepNow
{
    NSLog(@"System sleep requested");

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/pmset"];
    [task setArguments:@[@"sleepnow"]];
    [task launch];
    task = nil;
    
//    NSAppleScript *sleepForce = nil;
//    sleepForce = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to sleep"];
//    [sleepForce executeAndReturnError:nil];
//    sleepForce = nil;
}

-(void)enableShutEye
{
    NSLog(@"Enabling; ShutEye");
    shutEyeEnabled = true;
    [self shutEyeUpdateUI];
}
-(void)disableShutEye
{
    NSLog(@"Disabling shuteye");
    shutEyeEnabled = false;
    [self shutEyeUpdateUI];
}

-(void)systemOnReceiveSleepNote: (NSNotification*) note
{
    NSLog(@"receiveSleepNote: %@", [note name]);
    [self disableShutEye];
}

-(void)systemOnReceiveWakeNote: (NSNotification*) note
{
    NSLog(@"receiveWakeNote: %@", [note name]);
    
    // we woke up, better disable ourselves in case we werent the one causing the sleep
    [self disableShutEye];
}

-(void)systemMuteOutput
{
    NSLog(@"System mute requested");
    NSAppleScript *sleepForce = nil;
    sleepForce = [[NSAppleScript alloc] initWithSource:@"set volume with output muted"];
    [sleepForce executeAndReturnError:nil];
    sleepForce = nil;
}

-(void)systemFileForNotifications
{
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(systemOnReceiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(systemOnReceiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}


@end
