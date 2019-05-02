//
//  ViewController.swift
//  Project21
//
//  Created by henry on 01/05/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Regiter", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
    }
    
    
    @objc func registerLocal(){
        //
        let center = UNUserNotificationCenter.current()
// closure that will be executed when the user has granted or denied your permissions request.
        // This will be given two parameters: a boolean that will be true if permission was granted, and an Error? containing a message if something went wrong.
        center.requestAuthorization(options: [.alert, .badge, .sound]){
            (granted, error) in
            if granted {
                print("Yeah!!!")
            } else {
                print("Oh! NO")
            }
        }
    }
    
    // content (what to show), a trigger (when to show it), and a request (the combination of content and trigger.)
    @objc func scheduleLocal(){
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        // a calendar notification -> triggers requires learning another new data type called DateComponents
        var dateCompinents = DateComponents()
        dateCompinents.hour = 10
        dateCompinents.minute = 20
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompinents, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Good morning!"
        content.body = "Time to get up and play with Swift"
        // You can also attach custom actions by specifying the categoryIdentifier property.
        content.categoryIdentifier = "alarm"
        //To attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        //We can attach a custom data dictionary to our notifications.
       // This lets us provide context that gets sent back when the notification action is triggered.
        content.userInfo = ["customData": "henry"]
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories(){
        let center = UNUserNotificationCenter.current()
        //set the delegate property of the user notification center to be self, meaning that any alert-based messages that get sent will be routed to our view controller to be handled.
        center.delegate = self
        //Creating a UNNotificationAction requires three parameters:
        //For this technique project we’re going to create one button, “Show me more…”, that will cause the app to launch when tapped.
//        An identifier, which is a unique text string that gets sent to you when the button is tapped.
//        A title, which is what user’s see in the interface.
//        Options, which describe any special options that relate to the action. You can choose from .authenticationRequired, .destructive, and .foreground.
        let show = UNNotificationAction(identifier: "show", title: "Show more...", options: .foreground)
//Once you have as many actions as you want, you group them together into a single UNNotificationCategory and give it the same identifier you used with a notification.
        //Notification categories let us attach buttons to our notifications.
        //Each button can have its own action attached to it for custom behavior.
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String{
            print("The Name receive: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //the user swipe to unlock
                print("Default identifier")
                
            case "show":
                // the user tapped our "Show more.." button
                print("Show more INFO")
            default:
                break
            }
        }
        // you must call the completion handler when you're done
        completionHandler()
    }
}

