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
    @IBOutlet weak var MACField: NSTextField!
    @IBOutlet weak var interfaceField: NSTextField!
    @IBOutlet weak var interface: NSTextField!

    // MARK:- Initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Filling the fields.
        let interfaceName: String = "en0" // To be changed later.
        let fullOutput: Array = shell("/bin/bash", "ifconfig -a").components(separatedBy: " ")
        
        for i in 0 ..< fullOutput.count {
            if fullOutput[i].range(of: interfaceName) != nil {
                IPAddress.stringValue = fullOutput[i + 13]
                MACField.stringValue = fullOutput[i + 4]
                break
            }
        }
        
        interface.stringValue = interfaceName
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK:- Other functions
    
    func shell(_ launchPath: String, _ arguments: String) -> String {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = ["-c"] + [arguments]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }


}

