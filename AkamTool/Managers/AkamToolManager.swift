//
//  AkamToolManager.swift
//  AkamTool
//
//  Created by Astin on 1/29/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit

private let _sharedInstance = AkamToolManager()

class AkamToolManager: NSObject {
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
    let popover = NSPopover()

    let contentViewController = ContentViewController(nibName: "ContentViewController", bundle: nil)
    
    class func sharedInstance() -> AkamToolManager {
        return _sharedInstance
    }
    
    override init() {
        super.init()

        let icon = NSImage(named: "statusicon_default")
        icon?.setTemplate(true)
        self.statusItem.image = icon
        self.statusItem.target = self
        self.statusItem.action = "open"
        
        let button = self.statusItem.valueForKey("_button") as NSButton
        button.focusRingType = .None
        button.setButtonType(.PushOnPushOffButton)
        
        self.popover.contentViewController = self.contentViewController
        
        NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseUpMask | .LeftMouseDownMask, handler: { event in
            self.close()
        })
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask, handler: { (event) -> NSEvent in
            self.handleKeyCode(event.keyCode, flags: event.modifierFlags, windowNumber: event.windowNumber)
            return event
        })
        
    }
    
    func open() {
        if self.popover.shown {
            self.close()
            return
        }
        
        let button = self.statusItem.valueForKey("_button") as NSButton
        button.state = NSOnState
        
        NSApp.activateIgnoringOtherApps(true)
        self.popover.showRelativeToRect(NSZeroRect, ofView: button, preferredEdge: NSMaxYEdge)
        self.contentViewController?.updateHotKeyLabel()
    }
    
    func close() {
        if !self.popover.shown {
            return
        }
        
        let button = self.statusItem.valueForKey("_button") as NSButton
        button.state = NSOffState
        
        self.popover.close()
    }
    
    func handleKeyCode(keyCode: UInt16, flags: NSEventModifierFlags, windowNumber: Int) {
        let keyBinding = KeyBinding(keyCode: Int(keyCode), flags: Int(flags.rawValue))
        
        let window = NSApp.windowWithWindowNumber(windowNumber)
        if window? == nil {
            return
        }
        
        if window!.dynamicType.className() == "NSStatusBarWindow" {
            self.contentViewController?.handleKeyBinding(keyBinding)
        }
//        else if window!.windowController()? != nil && window!.windowController()! is PreferenceWindowController {
//            window!.windowController()!.handleKeyBinding(keyBinding)
//        }
    }
}

