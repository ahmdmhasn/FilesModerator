//
//  ContentViewModel.swift
//  SavingFilesDemo
//
//  Created by Ahmed M. Hassan on 08/08/2021.
//

import Foundation

class ContentViewModel: ObservableObject {
  @Published var imageData: Data?
  
  private let filesOrganizer = FilesOrganizer(folderName: "Images")
  
  func saveImage(_ data: Data) {
    filesOrganizer.saveFile("Image", with: "jpeg", data: data) { result in
      do {
        let url = try result.get()
        print("New URL is: \(url.path)")
      } catch {
        print(error)
      }
    }
  }
  
  func loadImage() {
    filesOrganizer.loadData("Image", pathExtension: "jpeg") { result in
      do {
        let data = try result.get()
        self.imageData = data
        print("Loaded Successfully!")
      } catch {
        print(error)
      }
    }
  }
  
  func removeAll() {
    filesOrganizer.removeFolder()
  }
}
