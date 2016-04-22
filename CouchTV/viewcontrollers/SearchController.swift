//
//  SearchController.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 16/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class SearchController: UICollectionViewController, UISearchResultsUpdating {
    
    static let storyboardIdentifier = "SearchResultsViewController"
    
    private var selectedMovie: Movie?
    
    private var movies: [Movie]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("search_coll_cell", forIndexPath: indexPath)
        
        if let _cell = cell as? SearchCollectionCell {
            
            _cell.poster.kf_cancelDownloadTask()
            _cell.poster.kf_showIndicatorWhenLoading = true
            
            let movie = self.movies?[indexPath.row]
            if let mainposter = movie?.mainPosterUrl {
                _cell.poster.kf_setImageWithURL(NSURL(string: mainposter)!)
            }
            
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 80
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30, left: 40, bottom: 30, right: 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 300, height: 438)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedMovie = self.movies?[indexPath.row]
        performSegueWithIdentifier("segue_search_detail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let view = segue.destinationViewController as? MovieViewController {
            view.movie = self.selectedMovie
        }
    }
    
    private var searchString: String? {
        didSet {
            guard searchString != oldValue else { return }
            
            MovieProviderManager.instance.search(searchString ?? "") {
                NSLog("Got \($0?.count) movies")
                self.movies = $0
            }
            
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        NSLog("Searching by \(searchController.searchBar.text)")
        searchString = searchController.searchBar.text ?? ""
    }
    
}