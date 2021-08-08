//
//  FileManager+Helpers.swift
//  SavingFilesDemo
//
//  Created by Ahmed M. Hassan on 08/08/2021.
//

import Foundation

// MARK: - FileManager
//
extension FileManager {
  
  /// Document directory
  ///
  var documentDirectory: URL {
    return urls(for: .documentDirectory, in: .userDomainMask)[.zero]
  }
  
  /// Discardable cache files (Library/Caches)
  ///
  var cachesDirectory: URL {
    return urls(for: .cachesDirectory, in: .userDomainMask)[.zero]
  }
}
