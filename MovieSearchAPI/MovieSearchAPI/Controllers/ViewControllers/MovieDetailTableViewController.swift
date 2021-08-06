//
//  MovieDetailTableViewController.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/6/21.
//

import UIKit

class MovieDetailTableViewController: UITableViewController {
    
    let searchController: UISearchController = {
        let controller = UISearchController()
        controller.hidesNavigationBarDuringPresentation = true
        controller.obscuresBackgroundDuringPresentation = false
        
        return controller
    }()
    
    var movieDetails = [MovieDetail]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchBar.delegate = self
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieDetails.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieDetailCell", for: indexPath) as? MovieDetailTableViewCell else { return UITableViewCell()}
        
        let movieDetail = movieDetails[indexPath.row]
        
        cell.updateViewsWith(movieDetail)
        
        return cell
    }
    
}//End Of VC


// MARK: - Search Bar Related

extension MovieDetailTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchKey = searchBar.text else { return }
        MovieDetailController.fetchMovies(searchKey) { [weak self] result in

            switch result {
            case .success(let details):
                self?.movieDetails = details
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let err):
                print(err)
            }


        }//End Of callback
    }
    
}//End Of extension

