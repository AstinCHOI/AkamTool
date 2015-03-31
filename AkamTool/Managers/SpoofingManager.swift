//
//  SpoofingManager.swift
//  AkamTool
//
//  Created by Astin on 2/8/15.
//  Copyright (c) 2015 Astin. All rights reserved.
//

import Foundation

class SpoofingManager {
    var dnsFlush: NSString = ""
    
    init() {
        let systemVersion = NSProcessInfo.processInfo().operatingSystemVersion;
        // { majorVersion, minorVersion, patchVersion }
        
        if systemVersion.majorVersion <= 10 {
            if(systemVersion.minorVersion >= 10) {
                dnsFlush = "/usr/sbin/discoveryutil mdnsflushcache; /usr/sbin/discoveryutil udnsflushcaches"
            } else if(systemVersion.minorVersion >= 7) {
                dnsFlush = "/usr/bin/killall -HUP mDNSResponder"
            } else if(systemVersion.minorVersion >= 5) {
                dnsFlush = "/usr/bin/dscacheutil -flushcache"
            } else if(systemVersion.minorVersion >= 3) {
                dnsFlush = "/usr/bin/lookupd -flushcache"
            }
        } else {
            dnsFlush = "/usr/bin/lookupd -flushcache"
        }
    }
    
    // Show /etc/hosts
    func loadHosts(inout dataArray: [NSMutableDictionary]) {
        let expandedPath = PathInfo.hostFile.stringByExpandingTildeInPath
        let data: NSData? = NSData(contentsOfFile: expandedPath)
        
        var contents = String()
        
        if data != nil {
            contents = NSString(data: data!, encoding:NSUTF8StringEncoding) as String
        }
        
        var arrayOfLines = [String]()
        arrayOfLines = contents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        
        var startInedx = 0;
        
        let regex = "^\\#*(" + RegexInfo.ip4 + ")|(" + RegexInfo.ip6 + ")+\\s[A-Za-z0-9\\.]+$"
        
        for i in 0 ... arrayOfLines.count - 2 {
            if(arrayOfLines[i].rangeOfString(regex, options: .RegularExpressionSearch) == nil) {
                continue
            }
            
            var hostToken = [String]()
            hostToken = arrayOfLines[i].componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (hostToken[1].isEmpty || hostToken[0] == "127.0.0.1" || hostToken[0] == "255.255.255.255") {
                continue
            }

            if hostToken[0].hasPrefix("#") {
                dataArray.append(["ip": hostToken[0], "host": hostToken[1], "comment": true])
            } else {
                dataArray.append(["ip": hostToken[0], "host": hostToken[1], "comment": false])
            }
        }
    }
    
    // Add Host
    func addHost(userHostInput: NSString) -> Bool {
        let outputDig = digTaskHelper(userHostInput)
        var isSuccess : Bool = false

        if outputDig != "" {
            let hosts = outputDig!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            for host in hosts { // LOOP ONE
                if host.rangeOfString(".akamaiedge.net.") != nil || host.rangeOfString(".akamai.net.") != nil {
                    let stagingHost = host.stringByReplacingOccurrencesOfString(".net.", withString: "-staging.net")

                    let outputDigStaging = digTaskHelper(stagingHost)
                    if outputDigStaging != "" {
                        let stagehosts = outputDigStaging!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        
                        for stagehost in stagehosts { // LOOP TWO
                            if stagehost != "" {
                                if addHostTaskHelper(stagehost + " " + userHostInput) == 0 {
                                    isSuccess = true
                                    break
                                }
                            }
                        }
                    }
                } // END CORE IF
            }
        }
        return isSuccess
    }
    
    // dig command
    func digTaskHelper(host: String) -> String? {
        let task = NSTask()
        task.launchPath = PathInfo.binSh
        task.arguments = ["-c", "dig +short " + host]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String? = NSString(data: data, encoding: NSUTF8StringEncoding)
        task.waitUntilExit()
        
        return output
    }
    
    // Add Host
    func addHostTaskHelper(line: String) -> Int32 {
        let task : STPrivilegedTask = STPrivilegedTask()
        
        task.setLaunchPath(PathInfo.binSh)
        task.setArguments(["-c", "echo " + line + " >> " + PathInfo.hostFile + ";" + dnsFlush])
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus()
    }
    
    // Comment Host
    func commentHosts(hosts: String) -> Int32 {
        // sudo sed -i "" "/127.0.0.1 localhost/d" /etc/hosts
        let task : STPrivilegedTask = STPrivilegedTask()
        
        task.setLaunchPath(PathInfo.binSh)
        task.setArguments(["-c", "sed -i \"\" \"" + hosts + "\" " + PathInfo.hostFile + ";" + dnsFlush])
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus()
    }
    
    // Remove Host
    func removeHosts(hosts: String) -> Int32 {
        // sudo sed -i "" "/127.0.0.1 localhost/d" /etc/hosts
        let task : STPrivilegedTask = STPrivilegedTask()
        
        task.setLaunchPath(PathInfo.binSh)
        task.setArguments(["-c", "sed -i \"\" \"" + hosts + "\" " + PathInfo.hostFile + ";" + dnsFlush])
        task.launch()
        task.waitUntilExit()
        
        return task.terminationStatus()
    }
}