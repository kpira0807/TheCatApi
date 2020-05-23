import UIKit

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var photos: [Photos] = []
    
    // delete cell in collection
    @IBOutlet private weak var deleteButton: UIBarButtonItem!
    @IBAction func deleteButton(_ sender: Any) {
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()
            for item in items {
                photos.remove(at: item)
            }
            collectionView.deleteItems(at: selectedCells)
            deleteButton.isEnabled = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotosCollectionViewCell
            cell.isInEditingMode = editing
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            deleteButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // size for collection cell
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
        searchImages()
        
        setupUI()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // size for collection cell
    let spacing:CGFloat = 10.0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 10
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells)
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionViewCell", for: indexPath) as?   PhotosCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        let informCell = photos[indexPath.row]
        cell.imageURL = URL(string: informCell.url!)
        // for delete
        cell.isInEditingMode = isEditing
        return cell
    }
    
    let networksManager = NetworksManager()
    
    // loading image in gallery
    func searchImages() {
        
        let request = NSMutableURLRequest(url: NSURL(string: networksManager.urlGallery)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = networksManager.headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                self.photos = try decoder.decode([Photos].self, from: data)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                self.showError(with: ErrorType.loading)
            }
        }.resume()
    }
    
    // Error message
    func showError(with type: ErrorType) {
        let myAlert = UIAlertController(title: "Error", message: type.rawValue, preferredStyle: .alert)
        let okeyAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        myAlert.addAction(okeyAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // take image in NavigationBar
    private let imageView = UIImageView(image: UIImage(named: "photos"))
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Constants.imageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Constants.imageRightMarginMax),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Constants.imageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
}
