//
//  MovieDetailTableViewCell.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/6/21.
//

import UIKit

class MovieDetailTableViewCell: UITableViewCell {
    
    

    @IBOutlet weak var movieImageView: UIImageView!
    
    @IBOutlet weak var movieNameLabel: UILabel!
    
    @IBOutlet weak var movieRatingLabel: UILabel!
    
    @IBOutlet weak var movieSummary: UITextView!
    
    var currentTask: URLSessionDataTask?
    
    func updateViewsWith(_ movieDetail: MovieDetail){
        movieRatingLabel.text = String(movieDetail.rating)
        movieSummary.text = movieDetail.summary
        
        guard let imageURLString = movieDetail.imageURLComponent else {
            movieNameLabel.text = movieDetail.name + " (No Poster Available)"
            return
        }
        
        movieNameLabel.text = movieDetail.name
        
        MovieDetailController.fetchImageFor(imageURLString) { [weak self] result, task in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                }
                self?.currentTask = task
                
            case .failure(let error):
                //TODO: better error handle for the images
                print(error)
            }
            
        }//End Of call back
        
    }//End Of func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let task = currentTask else { return }
        task.cancel()
        
    }

}//End Of Cell
