import UIKit

class BreedsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    // Search bar
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    var breeds = [Breeds]()
    
    // Search bar
    let searchController = UISearchController(searchResultsController: nil)
    var filteredBreeds = [Breeds]()
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let breed = breeds
        filteredBreeds = breed.filter({( breed : Breeds) -> Bool in
            return breed.name!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findBreeds()
        
        // Search bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    let networksManager = NetworksManager()
    
    func findBreeds() {
        activityIndicator.startAnimating()
        
        let request = NSMutableURLRequest(url: NSURL(string: networksManager.urlBreeds)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = networksManager.headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                self.breeds = try decoder.decode([Breeds].self, from: data)
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    self.tableView.reloadData()
                }
            } catch {
                self.showError(with: ErrorType.breed)
                self.activityIndicator.stopAnimating()
            }
        }.resume()
        
    }
    
    func showError(with type: ErrorType) {
        let myAlert = UIAlertController(title: "Error", message: type.rawValue, preferredStyle: .alert)
        let okeyAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        myAlert.addAction(okeyAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredBreeds.count
        }
        return breeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedsTableViewCell") as! BreedsTableViewCell
        var breed: Breeds
        if isFiltering() {
            breed = filteredBreeds[indexPath.row]
        } else {
            breed = breeds[indexPath.row]
        }
        cell.setup(with: breed)
        return cell
    }
    
    // go to detailed information about breed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInform" {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            let breed = breeds[indexPath.row]
            if let breedViewController: BreedViewController = segue.destination as? BreedViewController {
                breedViewController.breed = breed
            }
        }
    }
    
    // delete cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.breeds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

