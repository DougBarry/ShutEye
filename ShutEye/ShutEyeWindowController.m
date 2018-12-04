//
//  ShutEyeAppDelegate.h
//  ShutEye V0.3
//
//  Copyright (c) Douglas Barry 2014-2018
//  First version 20140825.
//  Last update 20181204.
//

#import "ShutEyeWindowController.h"

@interface ShutEyeWindowController ()

@end

@implementation ShutEyeWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        return self;
    } else {
        return nil;
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[self window] orderFrontRegardless];
    [[self window] setLevel:NSFloatingWindowLevel];
    [[self window] makeKeyAndOrderFront:nil];
}


@end
