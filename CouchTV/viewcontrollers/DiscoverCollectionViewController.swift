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
    
    override func viewWillAppear(_ animated: Bool) {
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
        let alert = UIAlertController(title: "Error", message: "Cannot!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default) { _ in
            self.tabBarController?.selectedIndex = 2
        })
        present(alert, animated: true, completion: .none)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.categories?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories?[section].movies?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "disc_coll_cell", for: indexPath as IndexPath)
        
        if let _cell = cell as? DiscoverCollectionCell {
            _cell.poster.kf.cancelDownloadTask()
            _cell.poster.kf.indicatorType = .activity
            
            let movie = getMovieByIndexPath(indexPath: indexPath)
            
            _cell.poster.kf.setImage(with: URL(string: movie.mainPosterUrl!)!,
                                     placeholder: #imageLiteral(resourceName: "placeholder"),
                                     options: [.transition(.fade(1))],
                                     progressBlock: .none,
                                     completionHandler: .none)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "disc_header_cell", for: indexPath as IndexPath)
        
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMovie = getMovieByIndexPath(indexPath: indexPath)
        self.performSegue(withIdentifier: "segue_show_movie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? MovieViewController {
            view.movie = self.selectedMovie
        }
    }
    
    private func getMovieByIndexPath(indexPath: IndexPath) -> Movie {
        return self.categories![indexPath.section].movies![indexPath.row]
    }
    
    
}
