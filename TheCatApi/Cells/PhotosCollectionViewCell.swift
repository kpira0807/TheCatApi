import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImage: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // delete mark
    @IBOutlet private weak var cheakmarkLabel: UILabel!
    
    override func layoutSubviews() {
        
        photoImage.layer.cornerRadius = 7
        photoImage.clipsToBounds = true
        
        cheakmarkLabel.textColor = UIColor.newRed
        cheakmarkLabel.clipsToBounds = true
    }
    
    var imageURL: URL? {
        didSet {
            photoImage.image = nil
            updateUI()
        }
    }
    
    private func updateUI() {
        if let url = imageURL {
            activityIndicator?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = data {
                            self.photoImage.image = UIImage(data: imageData)
                        }
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            }
        }
    }
    
    // delete cell
    var isInEditingMode: Bool = false {
        didSet {
            cheakmarkLabel.isHidden = !isInEditingMode
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                cheakmarkLabel.text = isSelected ? "✓" : ""
            }
        }
    }
}
