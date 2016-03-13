# Notify
Simplify usage of NSNotificationCenter

Install using CocoaPods:

```
pod 'Notify', :git => 'https://github.com/ivabra/Notify'
```


**Example:**

```swift
let BreakfastIsReadyNotification = "BreakfastIsReadyNotification"
let LunchIsReadyNotification =  "LunchIsReadyNotification"
let DinnerIsReadyNotification = "DinnerIsReadyNotification"

class Me: NSObject {
    var notifier: Notifier!

    func didReceiveHereIsSomeFoodNotification(notification: NSNotification){
    // Do something with food notificatins
    }

deinit {
        notifier.destroy()
     }
}

let me = Me()

me.notifier = notify(me)
.about(BreakfastIsReadyNotification, LunchIsReadyNotification, DinnerIsReadyNotification)
.to(Selector("didReceiveHereIsSomeFoodNotification:"))
//or .to(queue: NSOperationQueue, block: (NSNotification) -> Void)
//or .to(block: (NSNotification) -> Void)

postAbout(BreakfastIsReadyNotification, and: ["food" : ["Meal", "Potatoes"]])
```