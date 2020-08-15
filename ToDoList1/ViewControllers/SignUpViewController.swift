//
//  SignUpViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 07/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class SignUpViewController: UIViewController {
  
  @IBOutlet weak var googleLoginButton: UIButton!
  @IBOutlet weak var googleSignInView: UIView!
  @IBOutlet var firstNameTextField: UITextField!
  @IBOutlet var lastNameTextField: UITextField!
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var errorLabel: UILabel!
  @IBOutlet var signUpButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  func googleSignInSetup() {
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance()?.presentingViewController = self
    let googleSignInButton = GIDSignInButton()
    self.googleSignInView.addSubview(googleSignInButton)
  }
  
  @IBAction func googleLoginClicked(_ sender: UIButton) {
    GIDSignIn.sharedInstance().delegate = self
    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  @IBAction func signUpButtonTapped(_ sender: UIButton) {
    Analytics.logEvent("signUp_pressed", parameters: nil)
    
    if !Validation.isValidName(string: firstNameTextField.text) {
      errorLabel.text = "Incorrect FirstName"
      return
    }
    
    if !Validation.isValidName(string: lastNameTextField.text) {
      errorLabel.text = "Incorrect LastName"
      return
    }
    
    if !Validation.isValidEmail(string: emailTextField.text) {
      errorLabel.text = "Incorrect email"
      return
    }
    
    if !Validation.isValidPassword(string: passwordTextField.text) {
      errorLabel.text = "Incorrect Password"
      return
    }
    
    let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    
    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
      
      if error != nil {
        print("Error")
      } else {
        
        let db = Firestore.firestore()
        db.collection("users").addDocument(data: ["uid": result!.user.uid, "checkList": []]) { (error) in
          
          if error != nil {
            print("error")
          }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let checkListVc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        checkListVc.uid = result?.user.uid
        self.navigationController?.pushViewController(checkListVc, animated: true)
      }
    }
  }
}

extension SignUpViewController: GIDSignInDelegate {
  //MARK: Google Signup Response
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    if error != nil {
      print(error.localizedDescription)
      return
    } else {
      print("Successfully logged into Google", user!)
      
      guard  let idToken = user.authentication.idToken else  {
        return
      }
      
      guard let accessToken = user.authentication.accessToken else { return }
      
      let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
      
      Auth.auth().signIn(with: credentials) { (user, error) in
        if let error = error {
          print("Failed to create Firebase user with Google Account", error)
        }
        
        guard let uid = user?.user.uid else { return }
        print("Successfully Logged into Firebase",uid)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let checkListVc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(checkListVc, animated: true)
      }
    }
  }
}
