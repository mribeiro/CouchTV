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
    @IBOutlet var usernameLabel: UITextField!
    @IBOutlet var passwordLabel: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        testConnection()
    }
    
    override func viewDidLoad() {
        serverUrl.text = settingsManager.rootUrl?.absoluteString
        apiKeyTextField.text = settingsManager.apiKey
    }
    
    @IBAction func serverUrlChanged(_ sender: UITextField) {
        settingsManager.rootUrl = URL(string:sender.text!)
    }
    
    @IBAction func apiKeyChanged(_ sender: UITextField) {
        settingsManager.apiKey = sender.text
    }
    
    @IBAction func testConnectionClicked(_ sender: Any) {
        testConnection()
    }
    
    @IBAction func getKeyClicked(_ sender: Any) {
        self.movieManager.getKey(username: usernameLabel.text ?? "", password: passwordLabel.text ?? "") { (key) in
            
            guard let _key = key else {
                self.statusLabel.text = "Could not get key"
                return
            }
            
            self.apiKeyTextField.text = _key
            self.settingsManager.apiKey = _key
            self.testConnection()
            
        }
    }
    
    private func testConnection() {
        self.statusLabel.text = "Testing..."
        self.movieManager.testConnection {
            self.statusLabel.text = $0 ? "Success!" : "Failed"
        }
    }
}
