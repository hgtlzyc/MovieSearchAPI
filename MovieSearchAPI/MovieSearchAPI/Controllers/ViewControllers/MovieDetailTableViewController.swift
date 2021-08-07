//
//  MovieDetailTableViewController.swift
//  MovieSearchAPI
//
//  Created by lijia xu on 8/6/21.
//

import UIKit
import Combine

class MovieDetailTableViewController: UITableViewController {
    
    // MARK: - Display Mode
    enum TableViewDisplayMode {
        case readyForSearch
        case showResults
        case noMatchingResults
        case requestTimeOut
        case somethingWrong(String)
    }
    
    // MARK: - Views
    let searchController: UISearchController = {
        let controller = UISearchController()
        controller.hidesNavigationBarDuringPresentation = true
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.autocapitalizationType = .none
        
        return controller
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .large
        
        return indicator
    }()
    
    
    // MARK: - TableView Source of truth
    var movieDetails: [MovieDetail] = []
    var currentMode: TableViewDisplayMode = .readyForSearch
    
    // MARK: - Combine Related
    let searchKeyPublisher = PassthroughSubject<String,Never>()
    var subscriptions = Set<AnyCancellable>()
    
    let debounceInSeconds: Double = 0.5
    let requestTimeOutInSeconds: Int = 20
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialViews()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentMode {
        case .readyForSearch, .noMatchingResults , .somethingWrong(_), .requestTimeOut:
            return 1
        case .showResults:
            return movieDetails.count
        }
    }
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentMode {
        case .readyForSearch, .noMatchingResults, .requestTimeOut:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath) as? StatusTableViewCell else { return UITableViewCell()}
            
            if case .readyForSearch = currentMode {
                updateStatusCell(cell, "Enter Your Search Above", #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
            } else if case .noMatchingResults = currentMode {
                updateStatusCell(cell, "No Matching Result In Database", #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
            } else if case .requestTimeOut = currentMode {
                updateStatusCell(cell, "Request Time Out", #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1))
            }
            
            return cell
            
        case .somethingWrong(let message):
            let cell = UITableViewCell()
            cell.textLabel?.text = message
            cell.textLabel?.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            return cell
            
        case .showResults:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieDetailCell", for: indexPath) as? MovieDetailTableViewCell else { return UITableViewCell()}
            
            let movieDetail = movieDetails[indexPath.row]
            
            cell.updateViewsWith(movieDetail)
            
            return cell
            
        }
        
    }//End Of cellForRowAt
    
}//End Of VC


// MARK: - Search Bar Related
extension MovieDetailTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchKey = searchController.searchBar.text,
              !searchKey.isEmpty else {
            subscriptions.removeAll()
            changeDisplayModeTo(.readyForSearch)
            return
        }
        
        print(searchKey)
        
        setupCombine()
        searchKeyPublisher.send(searchKey)
        activityIndicator.startAnimating()
    }
    
}//End Of extension


// MARK: - Combine Related
extension MovieDetailTableViewController {
    
    func setupCombine(){
        guard subscriptions.isEmpty else { return }
        
        //debounce the search to the 'debounceInSeconds' set and reduce the API calls
        //also remove duplicate calls
        let filteredPublisher = searchKeyPublisher
            .debounce(for: .seconds(debounceInSeconds), scheduler: DispatchQueue.global())
            .removeDuplicates()
            .share()
        
        filteredPublisher
            .sink { [weak self] searchKey in
                self?.fetchMoviesWith(searchKey)
            }
            .store(in: &subscriptions)
        
        //set internet request time out and display message
        filteredPublisher
            .debounce(for: .seconds(requestTimeOutInSeconds), scheduler: DispatchQueue.global())
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    guard let isRunning = self?.activityIndicator.isAnimating,
                          isRunning else { return }
                    self?.activityIndicator.stopAnimating()
                    self?.changeDisplayModeTo(.requestTimeOut)
                }
            }
            .store(in: &subscriptions)
        
    }//End Of Setup Combine
    
    func fetchMoviesWith(_ searchKey: String) {

        MovieDetailController.fetchMovies(searchKey) { [weak self] result in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let details):
                    
                        guard !details.isEmpty else {
                            self?.changeDisplayModeTo(.noMatchingResults)
                            return
                        }
                        self?.changeDisplayModeTo(.showResults, with: details)
                    
                case .failure(let err):
                    switch err {
                    case .invalidURL(let err) :
                        self?.changeDisplayModeTo(.somethingWrong(err))
                        
                    case .thrownError(let err) :
                        self?.changeDisplayModeTo(.somethingWrong(err.localizedDescription))
                        
                    //API returns nil data when no search result, can prints err to console for debugging
                    case .nilData(_):
                        self?.changeDisplayModeTo(.noMatchingResults)
                        
                    case .unableToConertToImage:
                        self?.changeDisplayModeTo(.noMatchingResults)
                        
                    case .unableToDecodeData(_) :
                        self?.changeDisplayModeTo(.noMatchingResults)
                        
                    }
                    
                }//End Of switch
                
            }//End Of GCD
            
        }//End Of callback
        
    }//End Of fetchMoviesWith
    
}//End Of Extension


// MARK: - Display Helpers
extension MovieDetailTableViewController {
    
    func setupInitialViews() {
        //searchController related
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        
        tableView.backgroundView = activityIndicator
        activityIndicator.stopAnimating()
        
        tableView.separatorStyle = .none
    }

    // MARK: - Display Mode Change
    func changeDisplayModeTo(_ newMode: TableViewDisplayMode, with results: [MovieDetail] = []) {
        
        activityIndicator.stopAnimating()
        
        switch newMode {
        case .readyForSearch, .noMatchingResults , .somethingWrong(_), .requestTimeOut:
            guard results.isEmpty else { print("CHECK logic \(#function)") ; return }
            movieDetails = results
            
        case .showResults :
            guard !results.isEmpty else { print("CHECK logic \(#function)") ; return }
            movieDetails = results
        }
        
        currentMode = newMode
        tableView.reloadData()
        
    }//End Of func
    
    
    func updateStatusCell(_ cell: StatusTableViewCell,_ text: String,_ color: UIColor) {
        cell.updateLabelWithText(text)
        cell.statusLabel.textColor = color
    }
    
}//End Of Extension
