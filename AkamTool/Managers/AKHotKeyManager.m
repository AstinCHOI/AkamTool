//
//  AKHotKeyManager.m
//  AkamTool
//
//  Created by Astin on 1/29/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

#import "AkamTool-Swift.h"

#import <Carbon/Carbon.h>

#import "AKHotKeyManager.h"

@implementation AKHotKeyManager

/**
 * Reference : http://dbachrach.com/blog/2005/11/program-global-hotkeys-in-cocoa-easily/
 */
EventHotKeyRef hotKeyRef;

+ (void)registerHotKey
{
    EventHotKeyID hotKeyId;
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    // When hotkey event fired, hotKeyHandler is called.
    InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, NULL, NULL);
    
    // 4byte character
    hotKeyId.signature = 'akam';
    hotKeyId.id = 0;
    
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsKey.HotKey];
    KeyBinding *keyBinding;
    if (data) {
        keyBinding = [[KeyBinding alloc] initWithDictionary:data];
    } else {
        NSLog(@"No existing key setting.");
        keyBinding = [[KeyBinding alloc] init];
        keyBinding.shift = YES;
        keyBinding.command = YES;
        keyBinding.keyCode = 49; // Space
        [[NSUserDefaults standardUserDefaults] setObject:[keyBinding toDictionary] forKey:UserDefaultsKey.HotKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSLog(@"Bind HotKey : %@", keyBinding);
    
    UInt32 hotKeyModifiers = 0;
    if (keyBinding.shift) {
        hotKeyModifiers += shiftKey;
    }
    if (keyBinding.option) {
        hotKeyModifiers += optionKey;
    }
    if (keyBinding.control) {
        hotKeyModifiers += controlKey;
    }
    if (keyBinding.command) {
        hotKeyModifiers += cmdKey;
    }
    
    RegisterEventHotKey((UInt32)keyBinding.keyCode, hotKeyModifiers, hotKeyId, GetApplicationEventTarget(), 0,
                        &hotKeyRef);
    
    [[AkamToolManager sharedInstance].contentViewController updateHotKeyLabel];
}

+ (void)unregisterHotKey
{
    NSLog (@"Unbind HotKey");
    UnregisterEventHotKey(hotKeyRef);
}


#pragma mark -
#pragma mark HotKey

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    [[AkamToolManager sharedInstance] open];
    return noErr;
}

@end
