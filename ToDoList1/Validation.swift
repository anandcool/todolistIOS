//
//  Validation.swift
//  ToDoList1
//
//  Created by Nitin Kumar Singh on 07/08/20.
//  Copyright © 2020 Nitin Singh. All rights reserved.
//

import Foundation

struct Validation {
  
  static func isEmpty(string: String?) -> Bool {
    guard let str = string, !str.isEmpty else {
      return true
    }
    return false
  }
  
  static func isValidName(string: String?) -> Bool {
    guard !isEmpty(string: string) else { return false }
    return true
  }
  
  static func isValidPassword(string: String?) -> Bool {
    guard !isEmpty(string: string) else { return false }
    
    if let string = string, string.count >= 8 {
      return true
    } else {return false}
  }
  
  static func isValidEmail(string: String?) -> Bool {
     guard !isEmpty(string: string) else { return false }
     
     let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3}"
     let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
     return emailTest.evaluate(with: string)
   }
}
