//
//  LoginViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 07/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseFirestore

class LoginViewController: UIViewController {
  
  @IBOutlet var emailTextField: UITextField!
  @IBOutlet weak var googleSignInView: UIView!
  @IBOutlet weak var googleLoginButton: UIButton!
  @IBOutlet var passwordTextField: UITextField!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var errorLabel: UILabel!
  
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
  
  @IBAction func loginButtonTapped(_ sender: UIButton) {
    Analytics.logEvent("login_pressed", parameters: nil)
    
    if !Validation.isValidEmail(string: emailTextField.text) {
      errorLabel.text = "Incorrect email"
      return
    }
    if !Validation.isValidPassword(string: passwordTextField.text) {
      errorLabel.text = "Incorrect Password"
      return
    }
    
    let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
      if error != nil {
        self.errorLabel.text = error?.localizedDescription
      } else {
        
              let db = Firestore.firestore()
        
        db.collection("users").whereField("uid", isEqualTo: result?.user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
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

extension LoginViewController: GIDSignInDelegate {
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
        checkListVc.uid = user?.user.uid
        self.navigationController?.pushViewController(checkListVc, animated: true)
      }
    }
  }
}
