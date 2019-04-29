//
//  ActionViewController.swift
//  Extension
//
//  Created by henry on 25/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    
        //the extensionContext lets us control how the extension interacts with the parent app
        // the inputItems will be an array of data that parent app sends to our extension to use
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            //our input item contain an array of attachments, that wrapped up as an NSItemProvider
            if let itemProvider = inputItem.attachments?.first {
                // we use closure to executes code asynchronously
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String){
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    print(javaScriptValues)
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    // back to main thread, change UI
                    // the Closure being execited as a result of loadItem(forTypeIdentifier:) , could be called on any thread
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func done() {
//Calling completeRequest(returningItems:) on our extension context will cause the extension to be closed, returning back to the parent app
        //will pass back to the parent app any items that we specify, which in the current code is the same items that were sent in.
        
        //Create a new NSExtensionItem object that will host our items
        let item = NSExtensionItem()
        //Create a dictionary containing the key "customJavaScript" and the value of our script.
        let argument : NSDictionary = ["customJavaScript" : script.text!]
        //Put that dictionary into another dictionary with the key NSExtensionJavaScriptFinalizeArgumentKey.
        let webDictionary : NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument ]
        //Wrap the big dictionary inside an NSItemProvider object with the type identifier kUTTypePropertyList.
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        //Place that NSItemProvider into our NSExtensionItem as its attachments.
        item.attachments = [customJavaScript]
        //Call completeRequest(returningItems:), returning our NSExtensionItem.
        self.extensionContext!.completeRequest(returningItems: [item])
    }

    //Scroll indicator insets control how big the scroll bars are relative to their view.
@objc func adjustForKeyboard(notification: Notification){
    // NSValue exists because Objective-C couldn't put values like CGRect into arrays and dictionaries.
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    //TODO:  pull out the correct frame of the keyboard
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    // convert the rectangle to our view's co-ordinates.
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == UIResponder.keyboardWillHideNotification{
        script.contentInset = .zero
    } else {
        script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
    }
    //Content insets are specified using UIEdgeInsets
 //The contentInset property of a UITextView determines how text is placed inside the view.
    script.scrollIndicatorInsets = script.contentInset
    //make the text view scroll so that the text entry cursor is visible
    let selectedRange = script.selectedRange
    script.scrollRangeToVisible(selectedRange)
}
}
