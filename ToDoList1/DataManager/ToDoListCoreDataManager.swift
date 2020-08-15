//
//  ToDoListCoreDataManager.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 04/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ToDoListCoreDataManager {
  
  static let shared = ToDoListCoreDataManager()
  var todoItems = [Todo]()
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  func createObj(name: String, checkList: Task) {
    let task = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context) as! Todo
    task.todoName = name
    task.checkListItems = checkList
    saveContext()
  }
  
  func getNumberOfTasks() -> Int {
    return todoItems.count
  }
  
  func getTodoItem(index: Int) -> Todo {
    return todoItems[index]
  }
  
  func loadItems() -> [Todo] {
    let request = NSFetchRequest<Todo>(entityName: "Todo")
    request.sortDescriptors = [NSSortDescriptor(key: "todoName", ascending: true)]
    
    do {
      todoItems = try context.fetch(request)
    } catch {
      print(error.localizedDescription)
    }
    return todoItems
  }
  
  func saveContext() {
    do {
      try context.save()
    } catch {
      print("Error")
    }
  }
}

extension Todo {
  
  // to get an instance with specific name
  class func instance1(with name: String, index: Int) -> Todo? {
    
    let request = NSFetchRequest<Todo>(entityName: "Todo")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    request.predicate = NSPredicate(format: "todoName = %@", name)
    request.sortDescriptors = [NSSortDescriptor(key: "todoName", ascending: true)]
    
    do {
      let todoTasks = try context.fetch(request)
      
      for item in todoTasks {
        print(item.value(forKey: "todoName")!)
      }
      
      return todoTasks[0]
      
    } catch let error {
      print(error.localizedDescription)
      return nil
    }
  }
  
  func updateName1(with name: String, checkList: Task, mark: Bool) {
    self.todoName = name
    self.checkListItems = checkList
    self.marked = mark
    (UIApplication.shared.delegate as! AppDelegate).saveContext()
  }
}
