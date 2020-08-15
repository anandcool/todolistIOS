//
//  ViewController.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 04/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet var tableView: UITableView!
  var uid: String?
  var docId: String?
  var checkListArray: [String] = []
  let database = Firestore.firestore()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addBarButton()
    gestureRecognizer()
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
    database.collection("users").whereField("uid", isEqualTo: uid ?? "")
      .getDocuments() { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
        } else {
          for document in querySnapshot!.documents {
            self.docId = document.documentID
            print("\(document.documentID) => \(document.data()["checkList"] as! [String])")
            self.checkListArray = document.data()["checkList"] as! [String]
            self.tableView.reloadData()
          }
        }
    }
  }
  
  func addBarButton() {
    self.navigationController?.isNavigationBarHidden = false
    navigationController?.navigationBar.topItem?.title = "Checklists"
    let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
    button.setImage(UIImage(systemName: "plus"), for: .normal)
    button.addTarget(self, action: #selector(addButtonClicked), for: UIControl.Event.touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    
    let barButton = UIBarButtonItem(customView: button)
    self.navigationItem.rightBarButtonItem = barButton
  }
  
  func gestureRecognizer() {
    let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
    longPressGesture.minimumPressDuration = 1
    longPressGesture.delegate = self
    self.tableView.addGestureRecognizer(longPressGesture)
  }
  
  @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
    
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
      let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
      if let indexPath = tableView.indexPathForRow(at: touchPoint) {
        
        let text = checkListArray[indexPath.row]
        let name = text
        
        let addItemVc = storyboard?.instantiateViewController(identifier: "AddItemViewController") as! AddItemViewController
        addItemVc.check = 0
        addItemVc.editText = name
        addItemVc.editCount = indexPath.row
        addItemVc.title = "Edit Checklist"
        addItemVc.uid = uid
        addItemVc.docId = docId
        navigationController?.pushViewController(addItemVc, animated: true)
      }
    }
  }
  
  @objc func addButtonClicked() {
    pushToAddItemViewController()
  }
  
  func pushToAddItemViewController() {
    let addItemVc = storyboard?.instantiateViewController(identifier: "AddItemViewController") as! AddItemViewController
    addItemVc.title = "Add Checklist"
    addItemVc.check = 0
    addItemVc.uid = uid
    addItemVc.docId = docId
    navigationController?.pushViewController(addItemVc, animated: true)
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return checkListArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = checkListArray[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let todoVc = storyboard?.instantiateViewController(identifier: "AddTodoViewController") as! AddTodoViewController
    todoVc.title = "To Do"
    todoVc.uid = uid
    todoVc.docId = docId
    todoVc.cellIndex = indexPath.row
    navigationController?.pushViewController(todoVc, animated: true)
  }
}

