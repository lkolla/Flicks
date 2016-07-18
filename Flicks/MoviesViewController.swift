//
//  MovieViewController.swift
//  Flicks
//
//  Created by Rajesh Kolla on 7/16/16.
//  Copyright © 2016 walmart. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var displayErrorMessage: UILabel!
    let uiRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var movies :[NSDictionary] = []
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        uiRefreshControl.addTarget(self, action: #selector(MoviesViewController.reloadMovieTable), forControlEvents: .ValueChanged)
       
        EZLoadingActivity.show("Loading...", disableUI: true)
        
        movieTableView.addSubview(uiRefreshControl)

        updateMoives("now_playing")
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        
        let indexPath = self.movieTableView.indexPathForCell(cell)
        
        let movie = movies[indexPath!.row]
        
        let movieDetailsViewController = segue.destinationViewController as? MovieDetailsViewController
        movieDetailsViewController?.movie = movie
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("count \(self.movies.count)")

        
        return self.movies.count
        
        
    }
    
    func reloadMovieTable(){
            updateMoives("now_playing")
            uiRefreshControl.endRefreshing()
        
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieTableViewCell
        
        let movie = self.movies[indexPath.row]
        
        cell.movieTitleLable.text = movie["title"] as? String
        cell.movieDescriptionLabel.text = movie["overview"] as? String
        
        //let imageURL = "https://image.tmdb.org/t/p/w45" + (movie["poster_path"] as! String)
        
        cell.movieImage.setImageWithURL(NSURL(string:"https://image.tmdb.org/t/p/original" + (movie["poster_path"] as! String))!)
        
        print("count \(indexPath.row)")
        
        return cell
        
    }
    
    /*
     Following function take an url, makes rest call, update movies and table view.
    */
    func updateMoives(endpoint: String){
    
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        
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
                                                                                
                                                                                //NSLog("response: \(responseDictionary)")
                                                                                
                                                                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                                
                                                                                self.movieTableView.reloadData()
                                                                                
                                                                                if(self.movies.count == 0 ){
                                                                                    self.displayErrorMessage.hidden = false
                                                                                    EZLoadingActivity.hide(success: false, animated: true)
                                                                                }else{
                                                                                    self.displayErrorMessage.hidden = true
                                                                                    EZLoadingActivity.hide(success: true, animated: false)
                                                                                }
                                                                                
                                                                                
                                                                            }
                                                                        }
        })

        task.resume()
    
    }
    

}
