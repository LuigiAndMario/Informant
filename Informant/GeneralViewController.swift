//
//  ViewController.swift
//  Informant
//
//  Created by Luigi Sansonetti on 11.05.17.
//  Copyright © 2017 Luigi Sansonetti. All rights reserved.
//

import Cocoa
import Foundation

class GeneralViewController: NSViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var IPLabel: NSTextField!
    @IBOutlet weak var IPAddress: NSTextField!
    @IBOutlet weak var MACLabel: NSTextField!
    @IBOutlet weak var MACAddress: NSTextField!
    
    let interfaceName: String = "en0"

    // MARK:- Initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Finding the IP and MAC addresses.
        let outputAsArray: Array = bash("ifconfig -a").components(separatedBy: " ")
        var isAtInterface = false
        var hasMAC = false
        var hasIP = false
        
        for i in 0 ..< outputAsArray.count {
            if isAtInterface {
                if outputAsArray[i].range(of: "ether") != nil {
                    // MAC address
                    MACAddress.stringValue = outputAsArray[i + 1];
                    hasMAC = true
                } else if outputAsArray[i].range(of: "inet6") == nil && outputAsArray[i].range(of: "inet") != nil {
                    // IP address
                    IPAddress.stringValue = outputAsArray[i + 1]
                    hasIP = true
                }
                
                if hasMAC && hasIP {
                    break
                }
            } else if outputAsArray[i].range(of: interfaceName) != nil {
                isAtInterface = true
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK:- Bash command issuing
    
    func bash(_ arguments: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c"] + [arguments]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }


}

