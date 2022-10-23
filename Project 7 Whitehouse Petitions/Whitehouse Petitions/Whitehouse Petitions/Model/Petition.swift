//
//  Petition.swift
//  Whitehouse Petitions
//
//  Created by Nikita Novikov on 15.10.2022.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
