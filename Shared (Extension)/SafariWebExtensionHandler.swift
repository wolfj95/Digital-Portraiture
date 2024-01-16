//
//  SafariWebExtensionHandler.swift
//  Shared (Extension)
//
//  Created by Jacob Wolf on 1/15/24.
//

import SafariServices
import os.log
import RealmSwift

#if os(iOS)
let appGroupIdentifier = "group.com.example.Digital-Portraiture.group"
#elseif os(macOS)
let teamIdPrefix = Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") as! String
let appGroupIdentifier = "\(teamIdPrefix)com.example.Digital-Portraiture.group"
#endif

class Visit: Object {
   @Persisted(primaryKey: true) var _id: ObjectId
   @Persisted var url: String = ""
   @Persisted var status: String = ""
   @Persisted var ownerId: String
   convenience init(url: String, ownerId: String) {
       self.init()
       self.url = url
       self.ownerId = ownerId
   }
}

enum RequestType: String, Codable {
    case newPage
}

struct Message: Codable {
    var requestType: Optional<RequestType>
    var url: Optional<String>
    var user: Optional<String>
}



class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem, let userInfo = item.userInfo else { return }
                guard let arg = userInfo[SFExtensionMessageKey] as? CVarArg else { return }
                let message = String(format: "%@", arg)
        os_log(.default, "recieved request")
        guard let data = message.data(using: .utf8), let request = try? JSONDecoder().decode(Message.self, from: data) else { return }
//
                guard let requestType = request.requestType else { return }
        
                
                DispatchQueue.main.async {
                    var response: Any = ["type": "hello!"]
                    
                    switch requestType {
                    case .newPage:
                        guard let url = request.url, let user = request.user else { return }
                        
                        let fileURL = FileManager.default
                            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
                            .appendingPathComponent("default.realm")
                        let config = Realm.Configuration(fileURL: fileURL)
                        let realm = try! Realm(configuration: config)
                        
//                        let username = "testUser"
//                        var config = Realm.Configuration.defaultConfiguration
//                        config.fileURL!.deleteLastPathComponent()
//                        config.fileURL!.appendPathComponent(username)
//                        config.fileURL!.appendPathExtension("realm")
//                        let realm = try! Realm(configuration: config)
                        
                        let visit = Visit(url: url, ownerId: "test")
                        try! realm.write {
                            realm.add(visit)
                        }
                        let visits = realm.objects(Visit.self)
                        response = ["type": visits.count ]
                    }
                    let responseItem = NSExtensionItem()
                    responseItem.userInfo = [SFExtensionMessageKey: response]
                    context.completeRequest(returningItems: [responseItem], completionHandler: nil)
                }
    }

}
