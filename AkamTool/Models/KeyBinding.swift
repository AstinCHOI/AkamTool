//
//  KeyBinding.swift
//  AkamTool
//
//  Created by Astin on 1/30/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

private let _dictionaryKeys = ["keyCode", "shift", "control", "option", "command"]

public func ==(left: KeyBinding, right: KeyBinding) -> Bool {
    for key in _dictionaryKeys {
        if left.valueForKey(key) as Int != right.valueForKey(key) as Int {
            return false
        }
    }
    return true
}

@objc public class KeyBinding: NSObject {
    
    var keyCode: Int = 0
    var shift: Bool = false
    var control: Bool = false
    var option: Bool = false
    var command: Bool = false
    
    override public var description: String {
        var keys = [String]()
        if self.shift {
            keys.append("Shift")
        }
        if self.control {
            keys.append("Control")
        }
        if self.option {
            keys.append("Option")
        }
        if self.command {
            keys.append("Command")
        }
        
        let keyString = self.dynamicType.keyStringFormKeyCode(self.keyCode)
        if keyString? != nil {
            keys.append(keyString!.capitalizedString)
        }
        
        return " + ".join(keys)
    }
    
    @objc public override init() {
        super.init()
    }
    
    @objc public init(keyCode: Int, flags: Int) {
        super.init()
        self.keyCode = keyCode
        for i in 0...6 {
            if flags & (1 << i) != 0 {
                if i == 0 {
                    self.control = true
                } else if i == 1 {
                    self.shift = true
                } else if i == 3 {
                    self.command = true
                } else if i == 5 {
                    self.option = true
                }
            }
        }
    }
    
    @objc public init(dictionary: [NSObject: AnyObject]?) {
        super.init()
        if dictionary? == nil {
            return
        }
        for key in _dictionaryKeys {
            let value = dictionary![key] as? Int
            if value? != nil {
                self.setValue(value, forKey: key)
            }
        }
    }
    
    public func toDictionary() -> [String: Int] {
        var dictionary = [String: Int]()
        for key in _dictionaryKeys {
            dictionary[key] = self.valueForKey(key)!.integerValue
        }
        return dictionary
    }
    
    public class func keyStringFormKeyCode(keyCode: Int) -> String? {
        return keyMap[keyCode]
    }
    
    public class func keyCodeFormKeyString(string: String) -> Int {
        for (keyCode, keyString) in keyMap {
            if keyString == string {
                return keyCode
            }
        }
        return NSNotFound
    }
}

