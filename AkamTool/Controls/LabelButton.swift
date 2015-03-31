//
//  LabelButton.swift
//  AkamTool
//
//  Created by Astin on 1/31/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit

public class LabelButton: Label {
    
    public var normalTextColor: NSColor! = NSColor.blackColor()
    public var highlightedTextColor: NSColor! = NSColor(white: 0.5, alpha: 1)
    
    override public func mouseDown(theEvent: NSEvent?) {
        self.textColor = self.highlightedTextColor
    }
    
    override public func mouseUp(theEvent: NSEvent?) {
        self.textColor = self.normalTextColor
        
        if theEvent? != nil {
            let point = theEvent!.locationInWindow
            let rect = CGRectInset(self.frame, -10, -30)
            
            if NSPointInRect(point, rect) {
                self.sendAction(self.action, to: self.target)
            }
        }
    }
}