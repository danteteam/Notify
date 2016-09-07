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

public func postNotification(about something: String..., and andData : [AnyHashable: Any]? = nil, fromObject object: AnyObject? = nil) {
    let center = NotificationCenter.default
    something.forEach { center.post(name: Notification.Name(rawValue: $0), object: object, userInfo: andData) }
}

open class Notifier {
    
    fileprivate var intents = [Intent]()
    fileprivate weak var object: NSObject!
    fileprivate init(object: NSObject) {
        self.object = object
    }
    
   open  func about(_ something: String...) -> Intent {
        return Intent(parent: self, notificationNames: something)
    }
    
   open  func about(_ something: String..., fromObject object: NSObject) -> Intent {
        return Intent(parent: self, notificationNames: something, fromObject: object)
    }
    
    
   open  class Intent{
        fileprivate var selector: Selector!
        fileprivate var tokens: [NSObjectProtocol]!
        fileprivate let notificationNames: [String]
        fileprivate let parent: Notifier
        fileprivate weak var fromObject: NSObject?
        
        fileprivate init(parent: Notifier, notificationNames: [String], fromObject: NSObject? = nil) {
            self.parent = parent
            self.notificationNames = notificationNames
            self.fromObject = fromObject
        }
        
       open  func to(_ selector: Selector) -> Notifier {
            notificationNames.forEach {NotificationCenter.default.addObserver(parent.object, selector: selector, name: NSNotification.Name(rawValue: $0), object: fromObject) }
            
            return parent
        }
        
       open  func to(_ block: @escaping (Notification) -> Void) -> Notifier {
            return self.to(OperationQueue.main, block: block)
        }
        
        open func to(_ queue: OperationQueue, block: @escaping (Notification) -> Void) -> Notifier {
            tokens = notificationNames.map{NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: $0), object: fromObject, queue: queue, using: block)}
          
            return parent
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
