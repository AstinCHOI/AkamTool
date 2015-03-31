//
//  Label.swift
//  AkamTool
//
//  Created by Astin on 1/31/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import AppKit

public class Label: NSTextField {
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.bezeled = false
        self.editable = false
        self.backgroundColor = NSColor.clearColor()
    }
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}