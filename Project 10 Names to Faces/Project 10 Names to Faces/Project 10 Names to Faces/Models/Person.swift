//
//  Person.swift
//  Project 10 Names to Faces
//
//  Created by Nikita Novikov on 18.10.2022.
//

import UIKit

final class Person: NSObject, Codable, Identifiable {
    private(set) var id = UUID()
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}

// Save load data
extension Person {
    
}
