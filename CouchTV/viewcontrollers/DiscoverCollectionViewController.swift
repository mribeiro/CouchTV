//
//  DiscoverCollectionViewController.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 16/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class DiscoverCollectionViewController: UICollectionViewController {
    
    private var categories: [DiscoveryCategory]?
    private var selectedMovie: Movie?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MovieProviderManager.instance.getDiscovery {
            guard $0 != nil else {
                self.presentWarning()
                return
            }
            self.categories = $0
            self.collectionView?.reloadData()
        }
    }
    
    private func presentWarning() {
        let alert = UIAlertController(title: "Error", message: "Cannot!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Go to settings", style: .Default) { _ in
            self.tabBarController?.selectedIndex = 2
        })
        presentViewController(alert, animated: true, completion: .None)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.categories?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories?[section].movies?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let  cell = collectionView.dequeueReusableCellWithReuseIdentifier("disc_coll_cell", forIndexPath: indexPath)
        
        if let _cell = cell as? DiscoverCollectionCell {
            
            let movie = getMovieByIndexPath(indexPath)
            
            _cell.label.text = "\(indexPath.section) \(indexPath.row)"
            _cell.poster.kf_setImageWithURL(NSURL(string: movie.mainPosterUrl!)!)
        }
        
        return cell
        
    }
    
    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "disc_header_cell", forIndexPath: indexPath)
        
        if let _view = view as? DiscoverHeaderView {
            _view.label.text = self.categories![indexPath.section].name
        }
        
        return view
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
        self.selectedMovie = getMovieByIndexPath(indexPath)
        self.performSegueWithIdentifier("segue_show_movie", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let view = segue.destinationViewController as? MovieViewController {
            view.movie = self.selectedMovie
        }
    }
    
    private func getMovieByIndexPath(indexPath: NSIndexPath) -> Movie {
        return self.categories![indexPath.section].movies![indexPath.row]
    }
    
    
}
