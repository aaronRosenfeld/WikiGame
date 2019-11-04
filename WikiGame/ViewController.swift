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

//Three structs represent JSON object returned from wikipedia api call
//used for parsing and storing data
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
   
    @IBOutlet weak var timeLabel: UILabel!  //ui element which displays the time
    
    @IBOutlet weak var articleOneLabel: UILabel!    //ui element which displays name of starting aritcle
    
    @IBOutlet weak var articleTwoLabel: UILabel!    //ui element which displays name of destination article
    
    @IBOutlet weak var webView: WKWebView!  //ui element which displays the webpage
    
    var randomArticle1: String = "" //holds starting article name
    var randomArticle2: String = "" //holds destination article name
    
    var time = 0    //holds elapsed time
    var timer = Timer() //calls function at set interval
    
    var history: [String] = [] //holds titles of all wiki articles viewed
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getRandomArticles { resp, err in
            DispatchQueue.main.async {  //run in main thread
                if let resp = resp {
                    self.randomArticle1 = resp.query.random[0].title    //set starting article
                    self.randomArticle2 = resp.query.random[1].title    //set destination article
                }
                
                self.articleOneLabel.text = self.randomArticle1 //set starting article label
                self.articleTwoLabel.text = self.randomArticle2 //set destination article label
                
                //use starting article name to start webpage at starting article
                //replaces spaces with underscores per wikipedia URL format
                let viewURL = URL(string: "https://en.wikipedia.org/wiki/\(self.randomArticle1.replacingOccurrences(of: " ", with: "_"))")!
                let viewRequest = URLRequest(url: viewURL)
                self.webView.load(viewRequest)
                
            }
        }
        
        //add observer to view when webView's displayed title changes
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        
        //start timer and set interval
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.count), userInfo: nil, repeats: true)
        
    }
    
    //function called when timer increments
    @objc func count(){
        time += 1 //increment time variable
        let displayTime = "\(timeFormat(String(time/60))):\(timeFormat(String(time%60)))" //creates formated time display
        timeLabel.text = displayTime //sets ui element to display time
    }
    
    //function used to format seconds and minutes, adding '0' padding
    func timeFormat(_ time: String) -> String{
        return "\(String(String(time.reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed()))"
    }
    
    //function which calls the wikipedia api
    func getRandomArticles(randomCompletionHandler: @escaping (RandomResponse?, Error?) -> Void){
        //set url for api endpoint
        guard let randomURL = URL(string: "http://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=2") else { return }
        //create task to call api asyncronously
        URLSession.shared.dataTask(with: randomURL) { (data, response, error) in
            guard let data = data else { return }
            do{
                //decodes json response into struct defined earlier
                if let resp = try JSONDecoder().decode(RandomResponse?.self, from: data){
                    randomCompletionHandler(resp, nil) //calls callback completionhandler
                }
            } catch let jsonErr{    //handles error in parsing json
                print("Error:", jsonErr)
                randomCompletionHandler(nil, jsonErr)
            }
        }.resume() //runs task
    }
    
    //function which is called when a webView visits a new page
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = webView.title {
                //removes appended " - Wikipedia" from the page title
                //to get just the article title
                let fixedTitle = title.replacingOccurrences(of: " - Wikipedia", with: "")
                if(fixedTitle != "") {
                    history.append(fixedTitle)  //adds page title to history of viewd pages if not emptystring
                    //calls winCondition if the title of the article equals the destination article
                    if(fixedTitle == randomArticle2){ winCondition() }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let winScreen = segue.destination as! WinPageViewController
        winScreen.history = history
        winScreen.time = "\(timeFormat(String(time/60))):\(timeFormat(String(time%60)))"
    }
    
    //function called when the player wins
    func winCondition(){
        timer.invalidate()  //stops the timer
        self.performSegue(withIdentifier: "WinSegue", sender:nil)   //switch to win screen view
    }

}

