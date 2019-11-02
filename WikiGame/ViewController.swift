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
    
    var randomArticle1: String = ""
    var randomArticle2: String = ""
    
    var time = 0
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getRandomArticles { resp, err in
            DispatchQueue.main.async {
                if let resp = resp {
                    self.randomArticle1 = resp.query.random[0].title
                    self.randomArticle2 = resp.query.random[1].title
                }
                
                self.articleOneLabel.text = self.randomArticle1
                self.articleTwoLabel.text = self.randomArticle2
                
                let viewURL = URL(string: "https://en.wikipedia.org/wiki/\(self.randomArticle1.replacingOccurrences(of: " ", with: "_"))")!
                //print(viewURL)
                let viewRequest = URLRequest(url: viewURL)
                self.webView.load(viewRequest)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.count), userInfo: nil, repeats: true)
                
                
            }
        }
    }
    
    @objc func count(){
        time += 1
        let displayTime = "\(timeFormat(String(time/60))):\(timeFormat(String(time%60)))"
        timeLabel.text = displayTime
    }
    
    func timeFormat(_ time: String) -> String{
        return "\(String(String(time.reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()))"
    }
    
    func getRandomArticles(randomCompletionHandler: @escaping (RandomResponse?, Error?) -> Void){
        guard let randomURL = URL(string: "http://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=2") else { return }
        URLSession.shared.dataTask(with: randomURL) { (data, response, error) in
            guard let data = data else { return }
            do{
                if let resp = try JSONDecoder().decode(RandomResponse?.self, from: data){
                    randomCompletionHandler(resp, nil)
                }
//                randomCompletionHandler(resp, nil)
//                randomArticle1 = resp.query.random[0].title
//                randomArticle2 = resp.query.random[1].title
            } catch let jsonErr{
                print("Error:", jsonErr)
                randomCompletionHandler(nil, jsonErr)
            }
        }.resume()
    }


}

