import UIKit

class BreedsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var imageBreeds: UIImageView!
    @IBOutlet private weak var breedsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageBreeds.image = #imageLiteral(resourceName: "breeds")
        imageBreeds.clipsToBounds = true
    }
    
    func setup(with breed: Breeds) {
        breedsLabel.text = breed.name
    }
}
