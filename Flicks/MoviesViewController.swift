//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Carlos Avogadro on 1/5/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
// Pod library to represent succesfull load of application or failure
import EZLoadingActivity




class MoviesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var TableView: UITableView!
    
    
    //
    var refreshControl : UIRefreshControl!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
     self.TableView.insertSubview(refreshControl, atIndex: 0)
     
        
       TableView.delegate = self
        TableView.dataSource = self
        
        intitialCall()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        EZLoadingActivity.showWithDelay("Loading", disableUI: true,seconds: 0)
        if let movies = movies{
        return movies.count
        }
        else{
            return 0
        }
        
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell",forIndexPath: indexPath) as! MovieCell
       
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let imageUrl = NSURL(string: baseUrl+posterPath)
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)

        
    print("row \(indexPath.row)")
        return cell
    }
    
    func intitialCall() {
        
        let apiKey = "a90831142632346e26a5aa0c2d94ebf7"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.TableView.reloadData()
                             self.refreshControl.endRefreshing()
                            EZLoadingActivity.hide(success: true, animated: true)
                            
                           
                    }
                }
                else{
                    
                    EZLoadingActivity.hide(success: false, animated: true)
                    print("Failed")}
        });
        task.resume()
    }
    func onRefresh(){
    intitialCall()
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
