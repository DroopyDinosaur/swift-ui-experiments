//
//  ContentView.swift
//  SwiftUIExperiements
//
//  Created by Cory Loken on 12/8/19.
//  Copyright © 2019 Crunchy Bananas, LLC. All rights reserved.
//

import SwiftUI
import Combine

extension Model {
  class User: JSONModel, ObservableObject {
    @Published var id: String?
    @Published var name: String
    
    init(id: String? = nil, name: String) {
      self.id = id
      self.name = name
    }
    
    static var contents: [JSONModel] = []
    static var type = "users"
  }
  
  class Product: JSONModel, ObservableObject {
    @Published var id: String?
    @Published var product: String
    @Published var userId: String?
    
    init(id: String? = nil, product: String, userId: String? = nil) {
      self.id = id
      self.product = product
      self.userId = userId
    }
    
    var user: Model.User? {
      get {
        userId == nil ? nil : getRelationship(Model.User.type, relationId: userId!) as? Model.User
      }
      set(model) {
        setRelationship(Model.User.type, relationId: &userId, model: model)
      }
    }
    
    static var contents: [JSONModel] = []
    static var type = "products"
  }
}

class ObservableArray<T>: ObservableObject {
  @Published var array:[T] = []
  var cancellables = [AnyCancellable]()
  
  init(array: [T]) {
    self.array = array
  }
  
  func observeChildrenChanges<K>(_ type:K.Type) throws ->ObservableArray<T> where K : ObservableObject{
    let array2 = array as! [K]
    array2.forEach({
      let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
      
      // Important: You have to keep the returned value allocated,
      // otherwise the sink subscription gets cancelled
      self.cancellables.append(c)
    })
    return self
  }
}

class UserSettingsModel: ObservableObject {
  @Published var id: String
  @Published var isPublic: String
  
  init(id: String, isPublic: String = "No") {
    self.id = id
    self.isPublic = isPublic
  }
}

class UsersModel: ObservableObject {
  //  @Published var content: [UserModel] = []
  @ObservedObject var content: ObservableArray<UserModel> = try! ObservableArray(array: []).observeChildrenChanges(UserModel.self)
  
  //  var c: [UserModel] {
  //    get {
  //      return content.array
  //    }
  //  }
  
  func append(_ element: UserModel) {
    content.objectWillChange.send()
    content.$array.append([element])
  }
}

class UserModel: ObservableObject {
  @Published var id: String
  @Published var name: String
  
  init(id: String, name: String = "") {
    self.id = id
    self.name = name
  }
}

struct OneWayChildView: View {
  var text: String
  
  var body: some View {
    Text("Child view with parent -> child binding \(text)")
  }
}

struct TwoWayBindingChildView: View {
  @Binding var text: String
  
  var body: some View {
    VStack {
      TextField("Change binding from child", text: $text)
      Text("Child view value with @Binding: \(text)")
    }
  }
}

struct BindingWithEnvironmentView: View {
  @EnvironmentObject var settings: UserSettingsModel
  
  var body: some View {
    VStack {
      TextField("Change me from child view", text: $settings.isPublic)
      Text("Child view value with @EnvironmentObject: \(settings.isPublic)")
    }
  }
}

struct SiblingBindingWithEnvironmentView: View {
  @EnvironmentObject var settings: UserSettingsModel
  
  var body: some View {
    VStack {
      Text("Value in sibling via @EnvironmentObject: \(settings.isPublic)")
    }
  }
}

struct ListRenderView: View {
  @ObservedObject var users: ObservableArray<Model.User>
  
  var body: some View {
    VStack {
      Text("\(self.users.array.count)")
      
      List(users.array, id: \.uuid) { user in
        Text("\(user.uuid) \(user.name)")
      }
    }
  }
}

struct ListRowBindableView: View {
  @ObservedObject var user: Model.User
  
  var body: some View {
    TextField("Row", text: $user.name)
  }
}

struct ListBindingView: View {
  @ObservedObject var users: ObservableArray<Model.User>
  
  var body: some View {
    List(users.array, id: \.uuid) { user in
      ListRowBindableView(user: user)
    }
  }
}

struct ListBindingDemo: View {
  //  @EnvironmentObject private var users: UsersModel
  //  @ObservedObject private var user: Model.User = Model.User(name: "")
  @ObservedObject private var u: ObservableArray<Model.User> =  try! ObservableArray(array: []).observeChildrenChanges(Model.User.self)
  
  init() {
    Store.append("users", model: Model.User(id: "1", name: "From Store 1"))
    //    Store.append("users", models: [
    //      Model.User(id: "2", name: "From Store 2"),
    //      Model.User(id: "3", name: "From Store 3")]
    //    )
    //
    //    Store.append("products", model: Model.Product(id: "1", product: "From Product 1"))
    //    Store.append("products", model: Model.Product(id: "2", product: "From Product 2", userId: "1"))
    //
    u.array = Store.all("users") as! [Model.User]
    //    user = $u.array[0].wrappedValue
  }
  
  var body: some View {
    Form {
      Section(header: Text("List View Tests")) {
        Button(action: {
          Store.append("users", model: Model.User(id: "33", name: "Yo"))
          self.u.array = Store.all("users") as! [Model.User]
        }, label: {
          Text("Tap Me!")
        })
      }
      //      Section(header: Text("Render a list")) {
      //        ListBindingView(users: self.u)
      //      }
      Section(header: Text("Render a static list")) {
        ListRenderView(users: u)
      }
    }
  }
}

struct TextInputBindingDemoView: View {
  @ObservedObject var user: Model.User = Model.User(name: "yoyo")
  
  var body: some View {
    Form {
      Section(header: Text("Basic binding")) {
        TextField("Edit", text: $user.name)
        Text("Display: \(user.name)")
      }
      Section(header: Text("Two way @binding")) {
        TwoWayBindingChildView(text: $user.name)
      }
      Section(header: Text("One way var")) {
        OneWayChildView(text: user.name)
      }
      Section(header: Text("Using @EnvironmentObject")) {
        BindingWithEnvironmentView()
      }
      Section(header: Text("Render @EnvironmentObject")) {
        SiblingBindingWithEnvironmentView()
      }
    }
  }
}

struct ContentView: View {
  @ObservedObject var viewModel: ViewModel
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    TabView() {
      TextInputBindingDemoView().tabItem { Text("Text Inputs") }.tag(0)
      TextField("Sink it!", text: $viewModel.city)
        .font(.title)
        .tabItem {
          VStack {
            Image("second")
            Text("Second")
          }
      }
      .tag(1)
      ListBindingDemo().tabItem { Text("Tab Label 2") }.tag(2)
    }
  }
}

class ViewModel: ObservableObject, Identifiable {
  @Published var city: String = ""
  private var disposables = Set<AnyCancellable>()

  init(scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")) {
    _ = $city
      .dropFirst(1)
      .debounce(for: .seconds(0.5), scheduler: scheduler)
      .sink(receiveValue: {
        print($0)
      })
    .store(in: &disposables)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var settings = UserSettingsModel(id: "1", isPublic: "No")
  
  static var previews: some View {
    ContentView(viewModel: ViewModel()).environmentObject(settings)
  }
}
