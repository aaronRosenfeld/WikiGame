//
//  ViewController.swift
//  WikiGame
//
//  Created by Aaron Rosenfeld on 11/1/19.
//  Copyright © 2019 Aaron Rosenfeld. All rights reserved.
//

import UIKit
import WebKit
import Foundation

struct RandomResponse: Decodable{
    let query: Query
}

struct Query: Decodable{
    let random: [Random]
}

struct Random: Decodable{
    let id: Int
    let ns: Int
    let title: String
}

class ViewController: UIViewController {
   
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var articleOneLabel: UILabel!
    
    @IBOutlet weak var articleTwoLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var randomArticle1: String = ""
        var randomArticle2: String = ""
        guard let randomURL = URL(string: "http://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=2") else { return }
        URLSession.shared.dataTask(with: randomURL) { (data, response, error) in
            guard let data = data else { return }
            do{
                let resp = try JSONDecoder().decode(RandomResponse.self, from: data)
                //print(resp.query.random[0].title)
                randomArticle1 = resp.query.random[0].title
                print(randomArticle1)
                randomArticle2 = resp.query.random[1].title
                print(randomArticle2)
                //articleOneLabel.text = randomArticle1
            } catch let jsonErr{
                print("Error:", jsonErr)
            }
        }.resume()
        
        let viewURL = URL(string: "https://www.google.com")!
        let viewRequest = URLRequest(url: viewURL)
        webView.load(viewRequest)
        
    }


}

