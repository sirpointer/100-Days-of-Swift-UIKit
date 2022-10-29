//
//  WikiCapitalWebViewController.swift
//  Project 16 Capital Cities
//
//  Created by Nikita Novikov on 29.10.2022.
//

import UIKit
import WebKit

class WikiCapitalWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        view = webView
        
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let newURL = navigationAction.request.url
        
        if let host = newURL?.host(), host.localizedCaseInsensitiveContains("wikipedia.org") {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
