import Foundation

struct Breeds: Codable {
    let id: String?
    let name: String?
    let description: String?
    let life_span: String?
    let origin: String?
    let temperament: String?
    let weight: Weight
    let wikipedia_url: String?
    
    enum BreedsKeys: String, CodingKey {
        case id
        case name
        case description
        case life_span
        case origin
        case temperament
        case weight
        case wikipedia_url
    }
}

struct Weight: Codable {
    let metric: String?
}

struct BreedsImages: Codable {
    let url: String?
}


