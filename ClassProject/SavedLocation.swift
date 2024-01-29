//
//  SavedLocation.swift
//  ClassProject
//
//  Created by Derek McCants on 10/21/23.
//

import Foundation
import CoreLocation
import MapKit

struct coords: Decodable {
    var longitude: Double
    var latitude: Double
}

struct words: Decodable {
    var count: Int
    var words: [String]
}

class SavedLocation: ObservableObject, Identifiable, Hashable {
    static func == (lhs: SavedLocation, rhs: SavedLocation) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude;
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(longitude)
        hasher.combine(latitude)
    }
    var id: UUID
    @Published var longitude: Double
    @Published var latitude: Double
    @Published var words: String
    init(longitude: Double = 0.0, latitude: Double = 0.0) {
        self.id = UUID()
        self.longitude = longitude
        self.latitude = latitude
        words = "Converting Coordinates -> Words (Please wait)..."
        getWords(onFinish: {})
    }
    var coords : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var region : MKCoordinateRegion {
        return MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    /**
     * Location of the custom WordServer
     * NOTE: This is a custom API, you must have the server running to use it!
     *
     * Converts words --> coordinates and coordinates --> words
     * Return a JSON object
     */
    static let baseURL = "http://192.168.1.28:8080"
    func getFromWords(words: String, onFinish: @escaping () -> Void) {
        let words_array = words.split(separator: " ", maxSplits: 4)
        if(words_array.count < 4) {
            print("Err: Not enough words")
        }
        else {
            getFromWords(word1: String(words_array[0]), word2: String(words_array[1]), word3: String(words_array[2]), word4: String(words_array[3]), onFinish: onFinish)
        }
    }
    func getFromWords(word1: String, word2: String, word3: String, word4: String, onFinish : @escaping () -> Void) {
        
        let url = URL(string: SavedLocation.baseURL + "/convert/en/w2c?word1=\(word1)&word2=\(word2)&word3=\(word3)&word4=\(word4)")!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            do {
                let decodedData = try JSONDecoder().decode(ClassProject.coords.self, from: data!)
                DispatchQueue.main.async {
                    if decodedData.longitude >= -180 && decodedData.longitude <= 180 && decodedData.latitude >= -90 && decodedData.latitude <= 90 {
                        // prevent the API from crashing the app
                        self.words = "\(word1) \(word2) \(word3) \(word4)"
                        self.longitude = decodedData.longitude
                        self.latitude = decodedData.latitude
                        onFinish()
                    }
                }
            } catch {
                print("error: \(error)")
            }
        })
        jsonQuery.resume()
    }
    func getWords(onFinish: @escaping () -> Void) {
        let url = URL(string: SavedLocation.baseURL + "/convert/en/c2w?longitude=\(longitude)&latitude=\(latitude)")!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            do {
                let decodedData = try JSONDecoder().decode(ClassProject.words.self, from: data!)
                DispatchQueue.main.async {
                    self.words = decodedData.words.joined(separator: " ")
                    onFinish()
                }
            } catch {
                print("error: \(error)")
            }
        })
        jsonQuery.resume()
    }
}
