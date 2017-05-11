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
    
    let interfaceName: String = "en0"

    // MARK:- Initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Filling the fields.
        let outputAsArray: Array = bash("ifconfig -a").components(separatedBy: " ")
        for i in 0 ..< outputAsArray.count {
            if outputAsArray[i].range(of: interfaceName) != nil {
                IPAddress.stringValue = outputAsArray[i + 13]
                MACField.stringValue = outputAsArray[i + 4]
                break
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

