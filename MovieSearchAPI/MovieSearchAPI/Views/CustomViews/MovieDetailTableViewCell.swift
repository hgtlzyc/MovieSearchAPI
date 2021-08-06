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
    
    func updateViewsWith(_ movieDetail: MovieDetail){
        movieNameLabel.text = movieDetail.name
        movieRatingLabel.text = String(movieDetail.rating)
        movieSummary.text = movieDetail.summary
        
        MovieDetailController.fetchImageFor(movieDetail.imageURLComponent) { [weak self] result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                }
                
            case .failure(let error):
                print(error)
                
            }
            
        }//End Of call back
        
    }//End Of func

}//End Of Cell
