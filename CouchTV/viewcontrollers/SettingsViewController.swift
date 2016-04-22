//
//  SettingsViewController.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 19/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    private lazy var settingsManager = PreferencesProviderManager.instance
    private lazy var movieManager = MovieProviderManager.instance
    
    @IBOutlet weak var serverUrl: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        testConnection()
    }
    
    override func viewDidLoad() {
        serverUrl.text = settingsManager.rootUrl?.absoluteString
        apiKeyTextField.text = settingsManager.apiKey
    }
    
    @IBAction func saveSettingsClicked(sender: AnyObject) {
        settingsManager.apiKey = apiKeyTextField.text
        settingsManager.rootUrl = NSURL(string: serverUrl.text!)
        testConnection()
    }
    
    private func testConnection() {
        self.statusLabel.text = "Testing..."
        self.movieManager.testConnection {
            self.statusLabel.text = $0 ? "Success!" : "Failed"
        }
    }
}