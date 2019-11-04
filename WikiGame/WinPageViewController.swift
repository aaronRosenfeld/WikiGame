//
//  WinPageViewController.swift
//  WikiGame
//
//  Created by Aaron Rosenfeld on 11/4/19.
//  Copyright © 2019 Aaron Rosenfeld. All rights reserved.
//

import UIKit

class WinPageViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var historyCountLabel: UILabel!
            
    var time = String()    //holds elapsed time
    var history: [String] = [] //holds titles of all wiki articles viewed

    override func viewDidLoad() {
        super.viewDidLoad()

        timeLabel.text = "Time: \(time)";
        historyCountLabel.text = "Pages: \(history.count)"
            
        var text = String()
        for article in history{
            text.append("-\(article)\n")
        }
        
        // Do any additional setup after loading the view.
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
