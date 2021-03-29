//
//  CloudKitData.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/19/21.
//

import Foundation
import CloudKit

class CloudAuthData {
  private let id: CKRecord.ID
    public let clientID:String?
    public let clientSecret:String?
    public let clientSecretState:String?


  init(record: CKRecord) {
    id = record.recordID
    clientID = record["clientID"] as? String
    clientSecret = record["clientSecret"] as? String
    clientSecretState = record["clientSecretState"] as? String
  }
  
  static func fetchNotes(_ completion: @escaping (Result<[CloudAuthData], Error>) -> Void) {
    let query = CKQuery(recordType: "AuthData",
                        predicate: NSPredicate(value: true))
    let container = CKContainer.default()
        
    container.privateCloudDatabase.perform(query, inZoneWith: nil) { results, error in
      if let error = error {
        print("error here : \(error)")
        DispatchQueue.main.async {
          completion(.failure(error))
        }
        return
      }
        
      guard let results = results else {
        DispatchQueue.main.async {
          let error = NSError(
            domain: "iCloud.site.whiteoffice.Todoist", code: -1,
            userInfo: [NSLocalizedDescriptionKey:
                       "Could not download authData"])
          completion(.failure(error))
        }
        return
      }
      
      let notes = results.map(CloudAuthData.init)
      DispatchQueue.main.async {
        completion(.success(notes))
      }
    }
  }
}

extension CloudAuthData: Hashable {
  static func == (lhs: CloudAuthData, rhs: CloudAuthData) -> Bool {
    return lhs.clientID == rhs.clientID

  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(clientID)
  }
}

