//
//  Notify.swift
//  GuessPointApp
//
//  Created by Ivan Brazhnikov on 25/09/15.
//  Copyright © 2015 Ivan Brazhnikov. All rights reserved.
//

import Foundation


public func notify(_ who: NSObject) -> Notifier {
    return Notifier(object: who)
}

//public func postAbout(something: String..., and andData: [NSObject : AnyObject]? = nil, fromObject object: AnyObject? = nil) {
//    let center = NSNotificationCenter.defaultCenter()
//    something.forEach { center.postNotificationName($0, object: object, userInfo: andData) }
//}

public func postNotifications(names: Notification.Name..., and andData : [AnyHashable: Any]? = nil, fromObject object: AnyObject? = nil) {
    let center = NotificationCenter.default
    names.forEach { center.post(name: $0, object: object, userInfo: andData) }
}

open class Notifier {
    
    fileprivate var intents = Set<Intent>()
    //let weakToStrongMap  = NSMapTable<NSObject, NSArray>.weakToStrongObjects()
    fileprivate weak var object: NSObject!
    
    fileprivate init(object: NSObject) {
        self.object = object
    }
    
    open  func about(_ notifications: Notification.Name...) -> Intent {
        return Intent(parent: self, notificationNames: Set(notifications))
    }
    
   open  func about(_ notifications: Notification.Name..., fromObject object: NSObject) -> Intent {
        return Intent(parent: self, notificationNames: Set(notifications), fromObject: object)
    }
    
    
    open class Intent : Hashable {
        fileprivate var selector: Selector!
        fileprivate var tokens: [NSObjectProtocol]!
        fileprivate let notificationNames: Set<Notification.Name>
        fileprivate let parent: Notifier
        fileprivate weak var fromObject: NSObject?
        
        fileprivate init(parent: Notifier, notificationNames: Set<Notification.Name>, fromObject: NSObject? = nil) {
            self.parent = parent
            self.notificationNames = notificationNames
            self.fromObject = fromObject
        }
        
       open  func to(_ selector: Selector) -> Notifier {
            notificationNames.forEach {NotificationCenter.default.addObserver(parent.object, selector: selector, name: $0, object: fromObject) }
            return parent
        }
    
        open func to(queue: OperationQueue, block: @escaping (Notification) -> Void) -> Notifier {
            let tokens = notificationNames.map{NotificationCenter.default.addObserver(forName: $0, object: fromObject, queue: queue, using: block)}
            self.tokens = tokens
            return parent
        }
        
        public var hashValue: Int {
            return ObjectIdentifier(self).hashValue
        }
        
        public static func == (left: Intent, right: Intent) -> Bool {
            return left === right
        }
    }
    
   open func destroy(){
        let center = NotificationCenter.default
        if let o = object {
            center.removeObserver(o)
        }
    
        intents.forEach {
            if let tokens = $0.tokens {
                tokens.forEach {
                    center.removeObserver($0)
                }
            }
        }
        
    }
}
