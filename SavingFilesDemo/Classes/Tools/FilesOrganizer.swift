//
//  FilesOrganizer.swift
//  SavingFilesDemo
//
//  Created by Ahmed M. Hassan on 08/08/2021.
//

import Foundation

/// FilesOrganizer - Provide a layer  to save/ retrieve file in `.cachesDirectory` (Currently) asynchronously.
///
struct FilesOrganizer {
  
  typealias DataResult = Result<Data, Error>
  typealias URLResult = Result<URL, Error>
  
  // MARK: Properties
  
  /// Folder Name. Each object has it's own folder
  ///
  private let folderName: String
  
  /// Files Manager
  ///
  private let fileManager: FileManager
  
  /// Input/ Output Queue. Responsible for all background operations
  ///
  private let ioQueue: DispatchQueue
  
  // MARK: Init
  
  /// Init
  ///
  init(folderName: String,
       fileManager: FileManager = .default) {
    self.folderName = folderName
    self.fileManager = fileManager
    self.ioQueue = DispatchQueue(label: "com.iti.FilesOrganizer.ioQueue.(\(UUID().uuidString)")
  }
  
  // MARK: Handlers
  
  /// Save file in the folder
  ///
  /// - Parameters:
  ///   - named: File name
  ///   - pathExtension: File path extension
  ///   - data: Data to be stored
  ///   - callbackQueue: Callback queue. Default is `.main`
  ///   - onCompletion: Completion hander. Called on `callbackQueue`
  ///
  func saveFile(_ named: String,
                with pathExtension: String,
                data: Data,
                callbackQueue: DispatchQueue = .main,
                onCompletion: @escaping (URLResult) -> Void) {
    let content = FileMeta(fileName: named, pathExtension: pathExtension)
    saveFileInBackground(content: content, data: data) { result in
      callbackQueue.async { onCompletion(result) }
    }
  }
  
  
  /// Load data with inputs in the folder
  ///
  /// - Parameters:
  ///   - named: File name
  ///   - pathExtension: File path extension
  ///   - callbackQueue: Callback queue. Default is `.main`
  ///   - onCompletion: Completion hander. Called on `callbackQueue`
  ///
  func loadData(_ named: String,
                pathExtension: String,
                callbackQueue: DispatchQueue = .main,
                onCompletion: @escaping (DataResult) -> Void) {
    let content = FileMeta(fileName: named, pathExtension: pathExtension)
    loadDataInBackground(content: content) { result in
      callbackQueue.async { onCompletion(result) }
    }
  }

  
  /// Remove folder and all of it's content
  ///
  func removeFolder() {
    try? fileManager.removeItem(atPath: folderURL.path)
  }
}

// MARK: - Private Helpers
//
private extension FilesOrganizer {
  
  /// Current folder url
  ///
  var folderURL: URL {
    fileManager.cachesDirectory
      .appendingPathComponent(Defaults.subfolderName)
      .appendingPathComponent(folderName)
  }
  
  
  /// Create folder with `folderURL` if needed
  ///
  func prepareDirectory() throws {
    if !fileManager.fileExists(atPath: folderURL.path) {
      try fileManager.createDirectory(
        at: folderURL,
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
  }
  
  
  /// Create url in *folderURL* with `FileMeta
  ///
  func createFileURL(fileMeta: FileMeta) -> URL {
    return folderURL
      .appendingPathComponent(fileMeta.fileName)
      .appendingPathExtension(fileMeta.pathExtension)
  }
}

// MARK: - Background Load/ Retrieve
//
private extension FilesOrganizer {
  
  /// Save file with file meta to destination with url result when completed
  ///
  func saveFileInBackground(content: FileMeta,
                            data: Data,
                            onCompletion: @escaping (URLResult) -> Void) {
    let fileURL = createFileURL(fileMeta: content)
    
    ioQueue.async {
      do {
        try prepareDirectory()
        try data.write(to: fileURL)
        onCompletion(.success(fileURL))
      } catch {
        onCompletion(.failure(error))
      }
    }
  }
  
  
  /// Load data with file meta in the `iqQueue`. Result of data called on success.
  ///
  func loadDataInBackground(content: FileMeta,
                            onCompletion: @escaping (DataResult) -> Void) {
    let fileURL = createFileURL(fileMeta: content)
    
    ioQueue.async {
      do {
        let data = try Data(contentsOf: fileURL)
        onCompletion(.success(data))
      } catch {
        onCompletion(.failure(error))
      }
    }
  }
}

// MARK: - Nested Types
//
extension FilesOrganizer {
  
  struct FileMeta {
    let fileName: String
    let pathExtension: String
  }
}

// MARK: - Defaults
//
extension FilesOrganizer {

  enum Defaults {
    static let subfolderName = "FilesOrganizer"
  }
}
