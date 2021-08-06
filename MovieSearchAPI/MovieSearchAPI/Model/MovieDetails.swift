//
//  MovieDetails.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/6/21.
//

import Foundation

struct MivieDetailsTopLevelObject: Codable {
    let results: [MovieDetail]
}

struct MovieDetail: Codable {
    let name: String
    let rating: Double
    let summary: String
    let imageURLComponent: String
    
    enum CodingKeys: String, CodingKey {
        case name = "original_title"
        case rating = "vote_average"
        case summary = "overview"
        case imageURLComponent = "poster_path"
    }
}
