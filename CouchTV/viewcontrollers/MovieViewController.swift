//
//  MovieViewController.swift
//  CouchTV
//
//  Created by Antonio Ribeiro on 18/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire

class MovieViewController: UIViewController {
    
    var movie: Movie!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var movieSinopseTextView: UITextView!
    @IBOutlet weak var ratingProgressView: UIProgressView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var mpaaLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var seenButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        loadMovieData()
        //Alamofire.ParameterEncoding.encode(<#T##ParameterEncoding#>)
        
    }
    
    private func loadMovieData() {
        
        let imageUrl = URL(string: (self.movie.mainPosterUrl)!)!
        self.poster.kf.setImage(with: imageUrl)
        self.movieNameLabel.text = self.movie.name
        if let rating = self.movie.rating?.first, rating > 0 {
            self.ratingProgressView.setProgress(rating / 10, animated: true)
            
        } else {
            self.ratingProgressView.isHidden = true
        }
        
        self.movieSinopseTextView.text = movie.plot
        self.taglineLabel.text = movie.tagline
        self.mpaaLabel.text = movie.mpaa
        self.yearLabel.text = String(movie.year)
        
        if let movieLength = movie.length, movieLength > 0 {
            self.durationLabel.text = "\(movieLength) min"
        } else {
            self.durationLabel.isHidden = true
        }
        
        downloadButton.isEnabled = movie.imdbId != nil
        
        if let discoveryMovie = movie as? DiscoveryMovie {
            if !discoveryMovie.suggestion {
                seenButton.isHidden = true
            }
            
        } else {
            
            ignoreButton.isHidden = true
            seenButton.isHidden = true
        }
        
        
        switch movie.status {
        case .Downloaded:
            self.downloadButton.setTitle("Downloaded", for: .disabled)
            self.downloadButton.isEnabled = false
            
        case .Waiting:
            self.downloadButton.setTitle("Wanted", for: .disabled)
            self.downloadButton.isEnabled = false
            
        default: break
        }
        
    }
    
    @IBAction func downloadClicked(sender: AnyObject) {
        
        downloadButton.isEnabled = false
        downloadButton.setTitle("...", for: .disabled)
        
        self.ignoreButton.isEnabled = false
        self.seenButton.isEnabled = false
        
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
        
        MovieProviderManager.instance.fetchMovie(imdbId: movie.imdbId!) { result in
            if result {
                self.movie.status = .Waiting
                self.downloadButton.setTitle("Wanted", for: .disabled)
                
            } else {
                self.downloadButton.isEnabled = true
                self.downloadButton.titleLabel?.text = "Add"
                self.ignoreButton.isEnabled = true
                self.seenButton.isEnabled = true
            }
        }
    }
    
    @IBAction func ignoreClicked(_ sender: Any) {
        if let movie = self.movie as? DiscoveryMovie, movie.suggestion {
            seenOrIgnoredClickedSuggestion(false)
        } else {
            ignoreChart()
        }
        
    }
    
    @IBAction func seenClicked(_ sender: Any) {
        seenOrIgnoredClickedSuggestion(true)
    }
    
    private func seenOrIgnoredClickedSuggestion(_ markAsSeen: Bool) {
        MovieProviderManager.instance.ignoreSuggestion(imdbId: movie.imdbId!, andMarkAsSeen: markAsSeen) { (result) in
            if result {
                self.dismiss(animated: true, completion: .none)
            }
        }
    }
    
    private func ignoreChart() {
        MovieProviderManager.instance.ignoreChart(imdbId: movie.imdbId!) { (result) in
            if result {
                self.dismiss(animated: true, completion: .none)
            }
        }
    }
    
}
