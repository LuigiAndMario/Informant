//
//  Commands.swift
//  Informant
//
//  Created by Luigi Sansonetti on 12.05.17.
//  Copyright © 2017 Luigi Sansonetti. All rights reserved.
//

import Foundation

// MARK: Command issuing

/// Allows to issue a bash command and returns its output as a string.
func bash(_ arguments: String) -> String {
    let process = Process()
    process.launchPath = "/bin/bash"
    process.arguments = ["-c"] + [arguments]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
}

/// Allows to run a python program and returns its output as a string.
func python(_ name: String, _ ext: String, _ args: String...) -> String? {
    guard let scriptPath = Bundle.main.path(forResource: name, ofType: ext) else {
        return nil
    }
    
    var arguments = [scriptPath]
    for arg in args {
        arguments.append(arg)
    }
    
    let out = Pipe()
    let err = Pipe()
    let process = Process()
    
    process.launchPath = "/usr/bin/python"
    process.arguments = arguments
    process.standardInput = Pipe()
    process.standardOutput = out
    process.standardError = err
    process.launch()
    
    
    let data = out.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    
    let exitCode = process.terminationStatus
    if (exitCode != 0) {
        print("ERROR: \(exitCode)")
        return nil
    }
    
    return String(data: data, encoding: String.Encoding.ascii)
}
