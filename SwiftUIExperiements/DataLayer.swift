//
//  DataLayer.swift
//  SwiftUIExperiements
//
//  Created by Cory Loken on 12/10/19.
//  Copyright © 2019 Crunchy Bananas, LLC. All rights reserved.
//

import Swift
import Foundation

protocol JSONModel {
  var id: String? { get set }
  
  static var type: String { get }
}

extension JSONModel {
  var uuid: String {
    UUID().uuidString
  }
  
  func getRelationship(_ type: String, relationId: String) -> JSONModel? {
    Store.find(type, id: relationId) ?? nil
  }
  
  /// Method that abstracts the creation of relations in a model
  /// - Parameters:
  ///   - type: String The storage key used to lookup models in the store.
  ///   - relationId: String? The foriegn key
  ///   - model: JSONModel? A reference to the model that conforms to JSONModel
  func setRelationship(_ type: String, relationId: inout String?, model: JSONModel?) {
    if let m = model, let i = m.id {
      relationId = i
      if Store.find(type, id: i) == nil {
        Store.append(type, model: m)
      }
    } else {
      relationId = nil
    }
  }
}

extension Store {
  static var contents = [
    "users":  try! ObservableArray(array: []).observeChildrenChanges(Model.User.self),
    "products":  try! ObservableArray(array: []).observeChildrenChanges(Model.Product.self)
  ]
    
  static func all(_ type: String) -> [JSONModel]? {
    contents[type]?.array as? [JSONModel]
  }
  
  static func find(_ type: String, id: String) -> JSONModel? {
    contents[type]?.array.first(where: { ($0 as! JSONModel).id == id }) as? JSONModel
  }
  
  static func append(_ type: String, model: JSONModel) {
    contents[type]?.array.append(model)
  }
  
  static func append(_ type: String, models: [JSONModel]) {
    contents[type]?.array.append(contentsOf: models)
  }
}

enum Store {}
enum Model {}
