//
//  PeopleModel.swift
//  Project 10 Names to Faces
//
//  Created by Nikita Novikov on 06.11.2022.
//

import Foundation
import SwiftKeychainWrapper


final class PeopleModel {
    var people = [Person]()
    
    func loadPeople() -> [Person]? {
        if let peopleData = KeychainWrapper.standard.data(forKey: "people"),
           let people = try? JSONDecoder().decode([Person].self, from: peopleData) {
            return people
        } else {
            print("Cannot load saved people.")
            return nil
        }
    }
    
    func savePeople() {
        guard !people.isEmpty else { return }
        guard let peopleData = try? JSONEncoder().encode(people) else { return }
        KeychainWrapper.standard.set(peopleData, forKey: "people")
    }
    
    func removeUnusedImages() {
        let imagesDirectory = getImagesDirectory()
        guard let allImages = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else { return }
        
        for imageURL in allImages {
            let imageName = imageURL.lastPathComponent
            if !people.contains(where: { $0.image == imageName }) {
                try? FileManager.default.removeItem(at: imageURL)
            }
        }
    }
    
    
    func savePersonImage(imageName: String, imageData: Data) {
        let imagePath: URL = getImagesDirectory().appending(path: imageName)
        
        try? FileManager.default.createDirectory(at: getImagesDirectory(), withIntermediateDirectories: true)
        try? imageData.write(to: imagePath)
    }
    
    func getPersonImagePath(person: Person) -> URL {
        getImagesDirectory().appending(path: person.image)
    }
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getImagesDirectory() -> URL {
        getDocumentsDirectory().appending(component: "Names-to-Faces").appending(component: "Images")
    }
}
