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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "search_coll_cell", for: indexPath)
        
        if let _cell = cell as? SearchCollectionCell {
            
            _cell.poster.kf.cancelDownloadTask()
            _cell.poster.kf.indicatorType = .activity
            
            let movie = self.movies?[indexPath.row]
            if let mainposter = movie?.mainPosterUrl {
                _cell.poster.kf.setImage(with: URL(string: mainposter)!,
                                         placeholder: #imageLiteral(resourceName: "placeholder"),
                                         options: [.transition(.fade(1))],
                                         progressBlock: .none,
                                         completionHandler: .none)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMovie = self.movies?[indexPath.row]
        performSegue(withIdentifier: "segue_search_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? MovieViewController {
            view.movie = self.selectedMovie
        }
    }
    
    var timer: Timer?
    
    func set(_ movies: [Movie]?) {
        self.movies = movies
    }
    
    private var searchString: String? {
        didSet {
            guard searchString != oldValue else { return }
            
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                print("Searching by \(self.searchString)")
                MovieProviderManager.instance.search(searchTerm: self.searchString ?? "") {
                    NSLog("Got \($0?.count) movies")
                    self.movies = $0
                }
            }

        }
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        print("Search set to \(searchController.searchBar.text)")
        searchString = searchController.searchBar.text ?? ""
    }
    
}
