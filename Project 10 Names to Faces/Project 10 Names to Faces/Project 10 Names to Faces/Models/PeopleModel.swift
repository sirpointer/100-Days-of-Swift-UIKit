//
//  PeopleModel.swift
//  Project 10 Names to Faces
//
//  Created by Nikita Novikov on 06.11.2022.
//

import Foundation
import SwiftKeychainWrapper
import Combine


final class PeopleModel {
    var people = [Person]() {
        didSet {
            peopleUpdatedPassthroughSubject.send(people)
        }
    }
    
    private let peopleUpdatedPassthroughSubject = PassthroughSubject<[Person], Never>()
    private let imageSavedPassthroughSubject = PassthroughSubject<String, Never>()
    
    var peopleUpdatedPublisher: AnyPublisher<[Person], Never> {
        peopleUpdatedPassthroughSubject.eraseToAnyPublisher()
    }
    
    var imageSavedPublisher: AnyPublisher<String, Never> {
        imageSavedPassthroughSubject.eraseToAnyPublisher()
    }
    
    
    private let saveLoadImageQueue = DispatchQueue(label: "sirpointer.saveLoadImageQueue", qos: .background, attributes: .concurrent)
    private let saveLoadPeopleQueue = DispatchQueue(label: "sirpointer.saveLoadPeopleQueue", qos: .background)
    
    
    func loadPeople() {
        saveLoadPeopleQueue.async { [weak self] in
            if let peopleData = KeychainWrapper.standard.data(forKey: "people"),
               let people = try? JSONDecoder().decode([Person].self, from: peopleData) {
                DispatchQueue.main.async {
                    self?.people = people
                }
            } else {
                print("Cannot load saved people.")
            }
        }
    }
    
    func savePeople() {
        guard !people.isEmpty else { return }
        guard let peopleData = try? JSONEncoder().encode(people) else { return }
        saveLoadPeopleQueue.async(flags: .barrier) {
            KeychainWrapper.standard.set(peopleData, forKey: "people")
        }
    }
    
    func removeUnusedImages() {
        saveLoadImageQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let imagesDirectory = self.getImagesDirectory()
            guard let allImages = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else { return }
            
            for imageURL in allImages {
                let imageName = imageURL.lastPathComponent
                if !self.people.contains(where: { $0.image == imageName }) {
                    try? FileManager.default.removeItem(at: imageURL)
                }
            }
        }
    }
    
    
    func savePersonImage(imageName: String, imageData: Data) {
        saveLoadImageQueue.async { [weak self] in
            guard let self = self else { return }
            let imagePath: URL = self.getImagesDirectory().appending(path: imageName)
            
            try? FileManager.default.createDirectory(at: self.getImagesDirectory(), withIntermediateDirectories: true)
            try? imageData.write(to: imagePath)
            self.imageSavedPassthroughSubject.send(imageName)
        }
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
