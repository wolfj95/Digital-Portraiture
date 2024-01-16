//
//  ViewController.swift
//  Shared (App)
//
//  Created by Jacob Wolf on 1/15/24.
//

import WebKit
import RealmSwift
import os.log

#if os(iOS)
import UIKit
typealias PlatformViewController = UIViewController
#elseif os(macOS)
import Cocoa
import SafariServices
typealias PlatformViewController = NSViewController
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

let extensionBundleIdentifier = "com.example.Digital-Portraiture.Extension"
#if os(iOS)
let appGroupIdentifier = "group.com.example.Digital-Portraiture.group"
#elseif os(macOS)
let teamIdPrefix = Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") as! String
let appGroupIdentifier = "\(teamIdPrefix)com.example.Digital-Portraiture.group"
#endif

let username = "testUser"

class ViewController: PlatformViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.navigationDelegate = self

#if os(iOS)
        self.webView.scrollView.isScrollEnabled = false
#endif

        self.webView.configuration.userContentController.add(self, name: "controller")

        self.webView.loadFileURL(Bundle.main.url(forResource: "Main", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL)
        let realm = try! Realm(configuration: config)
        
//        var config = Realm.Configuration.defaultConfiguration
//        config.fileURL!.deleteLastPathComponent()
//        config.fileURL!.appendPathComponent(username)
//        config.fileURL!.appendPathExtension("realm")
//        let realm = try! Realm(configuration: config)
        
        let visits = realm.objects(Visit.self)
        print ("realm size:", visits.count)
//        print(visits[0].url)
//        let visits = ["test.com", "test2.com", "test3.com"]
#if os(iOS)
        webView.evaluateJavaScript("show('ios'), \(visits.count)")
#elseif os(macOS)
        webView.evaluateJavaScript("show('mac', \(visits.count)")

        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            guard let state = state, error == nil else {
                // Insert code to inform the user that something went wrong.
                return
            }

            DispatchQueue.main.async {
                if #available(macOS 13, *) {
                    webView.evaluateJavaScript("show('mac', \(visits.count), \(state.isEnabled), true)")
                } else {
                    webView.evaluateJavaScript("show('mac', \(visits.count), \(state.isEnabled), false)")
                }
            }
        }
#endif
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
#if os(macOS)
        if (message.body as! String == "open-preferences") {
            
            SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
                guard error == nil else {
                    // Insert code to inform the user that something went wrong.
                    return
                }
                
                DispatchQueue.main.async {
                    NSApp.terminate(self)
                }
            }
        } else if (message.body as! String == "send-msg-to-browser") {
            SFSafariApplication.dispatchMessage(withName: "Hello from App",
                                                toExtensionWithIdentifier: extensionBundleIdentifier,
                                                userInfo: ["AdditionalInformation": "Goes Here"],
                                                completionHandler: { (error) -> Void in
//                os_log(.default, "Dispatching message to the extension finished")
            })
        }
#endif
    }

}
