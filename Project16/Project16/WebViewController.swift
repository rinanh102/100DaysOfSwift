//
//  WebViewController.swift
//  Project16
//
//  Created by henry on 20/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView : WKWebView!
    var selecttedCapital : String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let capital = selecttedCapital {
            if let url = URL(string: "https://en.wikipedia.org/wiki/\(capital)"){
                webView.load(URLRequest(url: url))
                webView.allowsBackForwardNavigationGestures = true
            }
        }
    }

}
