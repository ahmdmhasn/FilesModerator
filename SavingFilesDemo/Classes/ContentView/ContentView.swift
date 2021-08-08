//
//  ContentView.swift
//  SavingFilesDemo
//
//  Created by Ahmed M. Hassan on 08/08/2021.
//

import SwiftUI

struct ContentView: View {
  var viewModel = ContentViewModel()
  @State var image = UIImage(named: "Wind-Turbine_UCSD_high")!
  
  var body: some View {
    Text("Hello, world!")
      .padding()
    
    Image(uiImage: image)
      .resizable()
      .frame(width:100, height:100)
      .onReceive(viewModel.$imageData) { data in
        if let data = data,
           let image = UIImage(data: data) {
          self.image = image
        }
      }
    
    Button("Save File") {
      let data = image.jpegData(compressionQuality: 0.5)
      doRepeatly {
        if let data = data {
          viewModel.saveImage(data)
        }
      }
    }
    
    Button("Load File") {
      doRepeatly {
        viewModel.loadImage()
      }
    }
    
    Button("Remove All") {
      viewModel.removeAll()
    }
  }
  
  func doRepeatly(action: @escaping () -> Void) {
    (0...1000).forEach { _ in
      action()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
