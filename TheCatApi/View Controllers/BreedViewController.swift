import UIKit

class BreedViewController: UIViewController{
    
    @IBOutlet private weak var imageBreed: UIImageView!
    @IBOutlet private weak var descriptionBreed: UILabel!
    @IBOutlet private weak var wikipediaButton: UIButton!
    @IBOutlet private weak var imageButton: UIButton!
    @IBOutlet private weak var originLabel: UILabel!
    @IBOutlet private weak var temperLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var lifeSpanLabel: UILabel!
    @IBOutlet private weak var viewLabels: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var breed: Breeds?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = breed?.name
        
        viewLabels.backgroundColor = UIColor.viewColor
        viewLabels.layer.cornerRadius = 10
        viewLabels.layer.borderColor = UIColor.skyBlue.cgColor
        viewLabels.layer.borderWidth = 1
        viewLabels.clipsToBounds = true
        
        wikipediaButton.backgroundColor = UIColor.skyBlue
        wikipediaButton.layer.cornerRadius = 7
        wikipediaButton.layer.borderColor = UIColor.lemonColor.cgColor
        wikipediaButton.layer.borderWidth = 1
        wikipediaButton.clipsToBounds = true
        
        imageButton.backgroundColor = UIColor.skyBlue
        imageButton.layer.cornerRadius = 7
        imageButton.layer.borderColor = UIColor.lemonColor.cgColor
        imageButton.layer.borderWidth = 1
        imageButton.clipsToBounds = true
        
        imageBreed.layer.cornerRadius = 7
        imageBreed.clipsToBounds = true
        
        descriptionBreed.text = breed?.description
        originLabel.text = breed?.origin
        temperLabel.text = breed?.temperament
        weightLabel.text = (breed?.weight.metric ?? "no information") + " kgs"
        lifeSpanLabel.text = (breed?.life_span ?? "no information") + " years"
        
        searchBreedImages()
    }
    
    @IBAction func wikipediaButton(_ sender: Any) {
        
        if let url = URL(string: breed?.wikipedia_url ?? "https://www.wikipedia.org") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func imageButton(_ sender: Any) {
        imageBreed.isHidden = true
        searchBreedImages()
    }
    
    let networksManager = NetworksManager()
    
    func searchBreedImages() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let request = NSMutableURLRequest(url: NSURL(string: "\(networksManager.urlBreed)\(breed?.id ?? "")")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = networksManager.headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let imageURL = try decoder.decode([BreedsImages].self, from: data)
                guard let url = URL(string: imageURL[0].url!) else {return}
                DispatchQueue.global(qos: .userInteractive).async {
                    let images = try? Data(contentsOf: url)
                    DispatchQueue.main.async{
                        self.imageBreed.isHidden = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidesWhenStopped = true
                        self.imageBreed.image = UIImage(data: images!)}
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
}
