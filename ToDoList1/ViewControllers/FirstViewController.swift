//
//  FirstViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 07/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {
  
  @IBOutlet var signUpButton: UIButton!
  @IBOutlet var loginButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  @IBAction func loginButtonTapped(_ sender: UIButton) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @IBAction func signUpButtonTapped(_ sender: UIButton) {
        Analytics.logEvent("signUpButton_pressed", parameters: nil)
    let signUp = storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
    navigationController?.pushViewController(signUp, animated: true)
  }
}
