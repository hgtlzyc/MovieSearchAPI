//
//  MovieDetailController.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/6/21.
//

import UIKit

enum MovieDetailError: LocalizedError {
    case invalidURL(String)
    case thrownError(Error)
    case nilData(String)
    case unableToDecodeData(Error)
    case unableToConvertToImage
}


struct MovieDetailController {
    static let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")
    
    private static let cache = NSCache<NSString,UIImage>()
    
    //https://api.themoviedb.org/3/search/movie?api_key=0b7911d1ad54efd1c1ab382103435cee&query=Jack+Reacher
    static func fetchMovies(_ keyWorld: String, completion: @escaping (Result<[MovieDetail],MovieDetailError>) -> Void) {
        
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL(baseURL?.absoluteString ?? "nil base URL"))) }
        
        let apiKey = "0b7911d1ad54efd1c1ab382103435cee"
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryItemAPIKey = URLQueryItem(name: "api_key", value: apiKey)
        let queryItemSearhWorld = URLQueryItem(name: "query", value: keyWorld)
        
        components?.queryItems = [queryItemAPIKey, queryItemSearhWorld]
        
        guard let finishedURL = components?.url else {
            return completion(
                .failure(.invalidURL(components?.url?.absoluteString ?? "nil finished url"))
            )
        }
        
        print(finishedURL.absoluteString)
        
        URLSession.shared.dataTask(with: finishedURL) { data, response, error in
            
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(.nilData("in \(#function)"))) }
            
        
            do {
                let movieTopLevelObject = try JSONDecoder().decode(MivieDetailsTopLevelObject.self, from: data)
                let movies = movieTopLevelObject.results
                
                completion(.success(movies))
            } catch {
                return completion(.failure(.unableToDecodeData(error)))
            }
            

        }.resume()
        
    }//End Of fetch movie with keyword
    
    //https://image.tmdb.org/t/p/w500
    static func fetchImageFor(_ imageURLString: String, completion: @escaping (Result<UIImage, MovieDetailError>, URLSessionDataTask?) -> Void) {
        var task: URLSessionDataTask?
        
        if let image = cache.object(forKey: imageURLString as NSString) {
            return completion(.success(image), task)
        }
        
        
        let imageBaseURL = URL(string: "https://image.tmdb.org/t/p/w500")
        
        guard let imageBaseURL = imageBaseURL else { return completion(
            .failure(.invalidURL(imageBaseURL?.absoluteString ?? "nil image base url")),
            task
        ) }
        
        let finishedURL = imageBaseURL.appendingPathComponent(imageURLString)
        
        
        task = URLSession.shared.dataTask(with: finishedURL) { data, response, error in
            
            if let error = error {
                return completion(
                    .failure(.thrownError(error)),
                    task
                )
            }
            
            guard let data = data else { return completion(
                .failure(.nilData("nil image data")),
                task
            ) }
            
            guard let image = UIImage(data: data) else {
                return completion(.failure(.unableToConvertToImage),task)
            }
            
            cache.setObject(image, forKey: imageURLString as NSString)
            
            completion(.success(image), task)
            
        }
        
        task?.resume()
    }//End Of func
    
}//End Of MovieDetailController


