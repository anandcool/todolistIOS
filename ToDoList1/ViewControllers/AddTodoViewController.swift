//
//  AddTodoViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 04/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AddTodoViewController: UIViewController , UIGestureRecognizerDelegate{
  
  @IBOutlet var todoTableView: UITableView!
  var cellIndex: Int?
  var cellName: String?
  var newText: String = ""
  var uid: String?
  var docId: String?
  var todoArray: [String] = []
  var todoDict: [String: Bool] = [:]
  let database = Firestore.firestore()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rightBarButton()
    gestureRecognizer()
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let cellText = cellIndex!
    cellName = String(cellText)
    
    database.collection("users").whereField("uid", isEqualTo: uid ?? "")
      .getDocuments() { (querySnapshot, error) in
        if let error = error {
          print("Error getting documents: \(error)")
          
        } else {
          for document in querySnapshot!.documents {
            self.docId = document.documentID
            if (document.get(self.cellName ?? "") != nil) {
              self.todoDict = document.data()[self.cellName!] as! [String:Bool]
              let keys = self.todoDict.keys
              
              self.todoArray = []
              for k in keys {
                self.todoArray.append(k)
              }
              self.todoTableView.reloadData()
              
            } else {
              
              let docData: [String: Any] = [
                self.cellName!: [:]
              ]
              self.database.collection("users").document(self.docId!).setData(docData, merge: true)
            }
          }
        }
    }
  }
  
  func gestureRecognizer() {
    let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
    longPressGesture.minimumPressDuration = 1
    longPressGesture.delegate = self
    self.todoTableView.addGestureRecognizer(longPressGesture)
  }
  
  @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
    
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
      
      let touchPoint = longPressGestureRecognizer.location(in: self.todoTableView)
      if let indexPath = todoTableView.indexPathForRow(at: touchPoint) {
        
        let text = todoArray[indexPath.row]
        let name = text
        
        let addItemVc = storyboard?.instantiateViewController(identifier: "AddItemViewController") as! AddItemViewController
        addItemVc.check = 1
        addItemVc.fieldName = cellName
        addItemVc.editCount = indexPath.row
        addItemVc.title = "Edit Item"
        addItemVc.uid = uid
        addItemVc.docId = docId
        addItemVc.editText = name
        navigationController?.pushViewController(addItemVc, animated: true)
      }
    }
  }
  
  func rightBarButton() {
    let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.addTarget(self, action: #selector(addTapped), for: UIControl.Event.touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    
    let barButton = UIBarButtonItem(customView: button)
    self.navigationItem.rightBarButtonItem = barButton
  }
  
  @objc func addTapped() {
    let addItemVc = storyboard?.instantiateViewController(identifier: "AddItemViewController") as! AddItemViewController
    addItemVc.title = "Add Item"
    addItemVc.check = 1
    addItemVc.uid = uid
    addItemVc.docId = docId
    addItemVc.fieldName = cellName
    navigationController?.pushViewController(addItemVc, animated: true)
  }
}

extension AddTodoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "todocell", for: indexPath)
    cell.selectionStyle = UITableViewCell.SelectionStyle.none
    cell.textLabel?.text = todoArray[indexPath.row]
    
    if todoDict[todoArray[indexPath.row]]! == true {
      cell.accessoryType = .checkmark
      
    } else {
      cell.accessoryType = .none
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if todoDict[todoArray[indexPath.row]]! == true {
      todoTableView.cellForRow(at: indexPath)?.accessoryType = .none
      todoDict[todoArray[indexPath.row]] = false
      
      let docData: [String: Any] = [
        self.cellName! : todoDict
      ]
      database.collection("users").document(self.docId!).setData(docData, merge: true)
      
    } else {
      
      todoTableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
      todoDict[todoArray[indexPath.row]] = true
      
      let docData: [String: Any] = [
        self.cellName! : todoDict
      ]
      database.collection("users").document(self.docId!).setData(docData, merge: true)
    }
  }
}
