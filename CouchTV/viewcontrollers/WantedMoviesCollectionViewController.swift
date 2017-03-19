//
//  WantedMoviesCollectionViewController.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 19/03/2017.
//  Copyright © 2017 Antonio Ribeiro. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class WantedMoviesCollectionViewController: UICollectionViewController {
    
    var moviesList: [DiscoveryMovie]?
    var selectedMovie: DiscoveryMovie!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MovieProviderManager.instance.getWanted { (movies) in
            self.moviesList = movies
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wanted_cell", for: indexPath)
        
        if let _cell = cell as? WantedCollectionCell,
            let movie = moviesList?[indexPath.row] {
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
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.moviesList != nil ? 1 : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.moviesList?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMovie = self.moviesList![indexPath.row]
        self.performSegue(withIdentifier: "segue_show_movie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? MovieViewController {
            view.movie = self.selectedMovie
        }
    }
    
    
    
}
