//
//  AddItemViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 04/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AddItemViewController: UIViewController {
  
  @IBOutlet var addItemTextField: UITextField!
  var check: Int?
  var editText: String?
  var newText = ""
  var editCount : Int?
  var updateText: String = ""
  var instanceText: String = ""
  var uid: String?
  var newString: [String] = []
  var docId: String?
  var fieldName: String?
  var todoString: [String] = []
  var todoDict: [String: Bool] = [:]
  let database = Firestore.firestore()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialSetUp()
    if editText != nil {
      self.addItemTextField.text = editText
      newText = editText!
      
    }
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    database.collection("users").whereField("uid", isEqualTo: uid ?? "")
      .getDocuments() { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
        } else {
          for document in querySnapshot!.documents {
            self.docId = document.documentID
            
            if self.check == 0 {
              self.newString = (document.data()["checkList"] as! [String])
              
            } else {
              self.todoDict = document.data()[self.fieldName!] as! [String:Bool]
              
              let keys = self.todoDict.keys
              for key in keys {
                self.todoString.append(key)
              }
            }
          }
        }
    }
  }
  
  func initialSetUp() {
    if check == 0 {
      addItemTextField.placeholder = "Name of the CheckList"
    } else {
      addItemTextField.placeholder = "Name of the Item"
    }
    
    let rightBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTask))
    self.navigationItem.rightBarButtonItem  = rightBarButton
    
    let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    self.navigationItem.leftBarButtonItem  = leftBarButton
  }
  
  @objc func cancel() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func saveTask() {
    guard let text = addItemTextField.text else {
      return
    }
    
    if check == 0 {
      if editCount != nil {
        updateText = addItemTextField.text!
        newString[editCount!] = updateText
        
        let docData: [String: Any] = [
          "uid": uid!,
          "checkList": newString
        ]
        database.collection("users").document(docId!).updateData(docData)
        self.navigationController?.popViewController(animated: true)
        
      } else {
        newString.append(text)
        
        let docData: [String: Any] = [
          "uid": uid!,
          "checkList": newString
        ]
        
        database.collection("users").document(docId!).setData(docData, merge: true ,completion: {
          (error) in
          if error == nil {
            self.navigationController?.popViewController(animated: true)
          } else {
            print("error")
          }
        })
      }
    } else {
      if editCount != nil {
        instanceText = editText!
        updateText = addItemTextField.text!
        
        let bool = todoDict[instanceText]
        
        todoDict.removeValue(forKey: instanceText)
        todoDict[updateText] = bool
        
        let docData: [String: Any] = [
          self.fieldName!  : todoDict
        ]
        
        database.collection("users").document(self.docId!).updateData(docData, completion: {(error) in
          
          if error == nil {
            self.navigationController?.popViewController(animated: true)
            
          } else {
            print("errorFound")
          }
        })
      }
        
      else {
        todoDict[text] = false
        
        let docData: [String: Any] = [
          self.fieldName!  : todoDict
        ]
        
        database.collection("users").document(self.docId!).setData(docData, merge: true, completion: { (error) in
          
          if error == nil {
            self.navigationController?.popViewController(animated: true)
            
          } else {
            print("errorFound")
          }
        })
      }
    }
  }
}
