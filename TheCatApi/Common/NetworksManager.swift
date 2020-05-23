import Foundation
import UIKit

struct NetworksManager {
    
    let headers = ["x-api-key": "9cccab3a-0151-4ef9-a53c-a506e40636aa"]
    let urlPhotos = "https://api.thecatapi.com/v1/images/search"
    let urlBreeds = "https://api.thecatapi.com/v1/breeds?attach_breed=0"
    let urlGallery = "https://api.thecatapi.com/v1/images/search?order=Desc&limit=100&page=0"
    let urlBreed = "https://api.thecatapi.com/v1/images/search?breed_id="
}
