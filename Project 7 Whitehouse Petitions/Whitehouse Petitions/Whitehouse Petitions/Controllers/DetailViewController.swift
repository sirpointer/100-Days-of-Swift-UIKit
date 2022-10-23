//
//  DetailViewController.swift
//  Whitehouse Petitions
//
//  Created by Nikita Novikov on 15.10.2022.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else { return }
        let html = getHtml(for: detailItem)

        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func getHtml(for petition: Petition) -> String {
        """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style> body { fontSize: 150%; } </style>
            </head>
                <body>
                    \(petition)
                </body>
        </html>
        """
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
