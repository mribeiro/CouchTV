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
    
    override func viewWillAppear(animated: Bool) {
        loadMovieData()
    }
    
    private func loadMovieData() {
        
        self.poster.kf_setImageWithURL(NSURL(string: (self.movie.mainPosterUrl)!)!)
        self.movieNameLabel.text = self.movie.name
        if let rating = self.movie.rating?.first {
            self.ratingProgressView.setProgress(rating / 10, animated: true)
            
        } else {
            self.ratingProgressView.hidden = true
        }
        
        self.movieSinopseTextView.text = movie.plot
        self.taglineLabel.text = movie.tagline
        self.mpaaLabel.text = movie.mpaa
        self.yearLabel.text = String(movie.year)
        
        if let movieLength = movie.length {
            self.durationLabel.text = "\(movieLength) min"
        } else {
            self.durationLabel.hidden = true
        }
        
        downloadButton.enabled = movie.imdbId != nil
        
        switch movie.status {
        case .Downloaded:
            self.downloadButton.setTitle("Downloaded", forState: .Disabled)
            self.downloadButton.enabled = false
            
        case .Waiting:
            self.downloadButton.setTitle("Wanted", forState: .Disabled)
            self.downloadButton.enabled = false
            
        default: break
        }
        
    }
    
    @IBAction func downloadClicked(sender: AnyObject) {
        
        downloadButton.enabled = false
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
        downloadButton.setTitle("Requesting...", forState: .Disabled)
        
        MovieProviderManager.instance.fetchMovie(movie.imdbId!) { result in
            if result {
                self.movie.status = .Waiting
                self.downloadButton.setTitle("Wanted", forState: .Disabled)
                
            } else {
                self.downloadButton.enabled = true
                self.downloadButton.titleLabel?.text = "Add"
            }
        }
    }
    
    
}