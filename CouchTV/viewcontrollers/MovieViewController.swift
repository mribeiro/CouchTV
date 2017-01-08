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
    
    override func viewWillAppear(_ animated: Bool) {
        loadMovieData()
        //Alamofire.ParameterEncoding.encode(<#T##ParameterEncoding#>)
        
    }
    
    private func loadMovieData() {
        
        let imageUrl = URL(string: (self.movie.mainPosterUrl)!)!
        self.poster.kf.setImage(with: imageUrl)
        self.movieNameLabel.text = self.movie.name
        if let rating = self.movie.rating?.first {
            self.ratingProgressView.setProgress(rating / 10, animated: true)
            
        } else {
            self.ratingProgressView.isHidden = true
        }
        
        self.movieSinopseTextView.text = movie.plot
        self.taglineLabel.text = movie.tagline
        self.mpaaLabel.text = movie.mpaa
        self.yearLabel.text = String(movie.year)
        
        if let movieLength = movie.length {
            self.durationLabel.text = "\(movieLength) min"
        } else {
            self.durationLabel.isHidden = true
        }
        
        downloadButton.isEnabled = movie.imdbId != nil
        
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
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
        downloadButton.setTitle("Requesting...", for: .disabled)
        
        MovieProviderManager.instance.fetchMovie(imdbId: movie.imdbId!) { result in
            if result {
                self.movie.status = .Waiting
                self.downloadButton.setTitle("Wanted", for: .disabled)
                
            } else {
                self.downloadButton.isEnabled = true
                self.downloadButton.titleLabel?.text = "Add"
            }
        }
    }
    
    
}
