//
//  CoreDataManager.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 04/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
  
  static let shared = CoreDataManager()
  var tasks = [Task]()
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  private init() {
    loadItems()
  }
  
  func createObj(name: String) {
    let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
    task.name = name
    saveContext()
  }
  
  func getNumberOfTasks() -> Int {
    return tasks.count
  }
  
  func getTodoItem(index: Int) -> Task {
    return tasks[index]
  }
  
  func loadItems() {
    
    let request = NSFetchRequest<Task>(entityName: "Task")
    do {
      tasks = try context.fetch(request)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func saveContext() {
    do {
      try context.save()
    } catch {
      print("Error")
    }
  }
}

extension Task {
  
  class func instance(with name: String, index: Int) -> Task? {
    
    let request = NSFetchRequest<Task>(entityName: "Task")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    do {
      let tasks = try context.fetch(request)
      return tasks[index]
      
    } catch let error {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func updateName(with name: String) {
    self.name = name
    (UIApplication.shared.delegate as! AppDelegate).saveContext()
  }
}
