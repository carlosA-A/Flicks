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

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //
    var refreshControl : UIRefreshControl!
    var endpoint : String!
    
    var movies: [NSDictionary]?
    
    var moviesFilter: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EZLoadingActivity.showWithDelay("Loading", disableUI: false, seconds: 3)
        
        //errorTouch.addTarget(self, action: "onTap:")
        //Navigation bar editing
        if let navigationBar = navigationController?.navigationBar { navigationBar.tintColor = UIColor(red: 1.0, green: 0.25, blue: 0.10, alpha: 0.8)
            navigationBar.translucent = true
            
            navigationBar.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(17),
                NSForegroundColorAttributeName : UIColor(red: 1, green: 0.25, blue: 0.10, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
    
        
        
        
        refreshControl = UIRefreshControl()
        //calls function to reload data on display
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
     self.TableView.insertSubview(refreshControl, atIndex: 0)
     
        
       TableView.delegate = self
        TableView.dataSource = self

        //function to load API data
        
        intitialCall()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        

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
        //No higlighted cells
        cell.selectionStyle = .None
        
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        if let posterPath = movie["poster_path"] as? String{
        let imageUrl = NSURL(string: baseUrl+posterPath)
       // cell.posterView.setImageWithURL(imageUrl!)
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            cell.posterView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                        })
                    } else {
                        cell.posterView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        

        
 
        return cell
    }
    
    func intitialCall() {
        

        let apiKey = "a90831142632346e26a5aa0c2d94ebf7"

        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
       // let request = NSURLRequest(URL: url!)

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
//                            NSLog("response: \(responseDictionary)")
                            self.errorLabel.hidden = true

                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.TableView.reloadData()
                            self.refreshControl.endRefreshing()
                            EZLoadingActivity.hide(success: true, animated: true)
                            
                                              }
                }
               
                else{
                    
                    self.errorLabel.hidden = false
                    EZLoadingActivity.hide(success: false, animated: true)
                    self.refreshControl.endRefreshing()
                }
        } );
        task.resume()
    }
    func onRefresh(){
    intitialCall()
        
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? UITableViewCell{
        let indexPath = TableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

    @IBAction func errorTouch(sender: AnyObject) {
        onRefresh()
    }

}
