# Live Search From API Using Combine
![](https://github.com/hgtlzyc/MovieSearchAPI/blob/2908d440d020a293f93d8950e418eb0edf22c3e5/MovieSearch.gif)
 - API
 - Combine
 - URL Session

#### Code snippet:
```swift
    //(Sample Console Log)
    //h 2021-08-07 07:28:19 +0000
    //receive subscription: (RemoveDuplicates)
    //request unlimited                //new subscription created
    //ha 2021-08-07 07:28:19 +0000
    //har 2021-08-07 07:28:19 +0000
    //harr 2021-08-07 07:28:19 +0000
    //harry 2021-08-07 07:28:19 +0000  //debounce
    //receive value: (harry)
    //https://api.themoviedb.org/3/search/movie?api_key=****11d1ad54efd1c1ab382103435cee&query=harry
    //harr 2021-08-07 07:28:45 +0000
    //harry 2021-08-07 07:28:45 +0000  //remove duplicates
    //harr 2021-08-07 07:28:53 +0000
    //har 2021-08-07 07:28:53 +0000
    //ha 2021-08-07 07:28:53 +0000
    //h 2021-08-07 07:28:53 +0000
    //receive cancel                   //subscription canceled

    func setupCombine(){
        guard subscriptions.isEmpty else { return }
        
        //debounce the search to the 'debounceInSeconds' and reduce the API calls
        //also remove duplicate calls
        let filteredPublisher = searchKeyPublisher
            .debounce(for: .seconds(debounceInSeconds), scheduler: DispatchQueue.global())
            .removeDuplicates()
            //.print()
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
    
``
