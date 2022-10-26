//
//  PersonCell.swift
//  Project 10 Names to Faces
//
//  Created by Nikita Novikov on 18.10.2022.
//

import UIKit

protocol ImageViewTappedDelegateProtocol: AnyObject {
    func didImageViewTappedCell(cell: PersonCell)
}

class PersonCell: UICollectionViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    weak var person: Person?
    
    var imageViewTappedDelegate: ImageViewTappedDelegateProtocol?
    
    @objc func imageViewTapped() {
        imageViewTappedDelegate?.didImageViewTappedCell(cell: self)
    }
}
