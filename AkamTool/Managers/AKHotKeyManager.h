//
//  AKHotKeyManager.h
//  AkamTool
//
//  Created by Astin on 1/29/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef AkamTool_AKHotKeyManager_h
#define AkamTool_AKHotKeyManager_h

@interface AKHotKeyManager : NSObject

+ (void)registerHotKey;
+ (void)unregisterHotKey;

@end


#endif
