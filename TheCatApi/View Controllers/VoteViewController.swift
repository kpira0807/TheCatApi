import UIKit

class VoteViewController: UIViewController {
    
    @IBOutlet private weak var imageVote: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dislikeButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let imageView = UIImageView(image: UIImage(named: "vote"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageVote.clipsToBounds = true
        imageVote.layer.cornerRadius = 7
        
        likeButton.backgroundColor = UIColor.newGreen
        likeButton.layer.cornerRadius = 5
        likeButton.clipsToBounds = true
        
        dislikeButton.backgroundColor = UIColor.newRed
        dislikeButton.layer.cornerRadius = 5
        dislikeButton.clipsToBounds = true
        
        loadImages()
        
        setupUI()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Constants.imageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Constants.imageRightMarginMin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Constants.imageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
    }
    
    var vote = [Photos]()
    let networksManager = NetworksManager()
 
    func loadImages()  {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        likeButton.isEnabled = false
        dislikeButton.isEnabled = false

        let request = NSMutableURLRequest(url: NSURL(string: networksManager.urlPhotos)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = networksManager.headers
        
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let imageURL = try decoder.decode([Photos].self, from: data)
                guard let url = URL(string: imageURL[0].url!) else {return}
                DispatchQueue.global(qos: .userInteractive).async {
                    let images = try? Data(contentsOf: url)
                    DispatchQueue.main.async{
                        self.imageVote.isHidden = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                        self.dislikeButton.isEnabled = true
                        self.likeButton.isEnabled = true
                        self.imageVote.image = UIImage(data: images!)}
                }
            } catch {
                self.showError(with: ErrorType.loading)
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
    
    @IBAction func likeButton(_ sender: Any) {
        imageVote.isHidden = true
        loadImages()
    }
    
    @IBAction func dislikeButton(_ sender: Any) {
        imageVote.isHidden = true
        loadImages()
    }
}
