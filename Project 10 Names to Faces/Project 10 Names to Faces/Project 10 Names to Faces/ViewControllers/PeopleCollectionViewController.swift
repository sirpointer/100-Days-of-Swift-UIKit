//
//  ViewController.swift
//  Project 10 Names to Faces
//
//  Created by Nikita Novikov on 18.10.2022.
//

import UIKit
import SwiftKeychainWrapper

class PeopleCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageViewTappedDelegateProtocol {

    let peopleModel = PeopleModel()
    
    private var editableCell: PersonCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loadedPeople = peopleModel.loadPeople() {
            peopleModel.people = loadedPeople
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addOrEditPerson))
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActiveAction), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    @objc func willResignActiveAction() {
        DispatchQueue.global().async { [weak self] in
            self?.peopleModel.savePeople()
            self?.peopleModel.removeUnusedImages()
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        peopleModel.people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to deqeue PersonCell.")
        }
        
        let person = peopleModel.people[indexPath.item]
        
        cell.person = person
        cell.name.text = person.name
        
        let path = peopleModel.getPersonImagePath(person: person)
        cell.imageView.image = UIImage(contentsOfFile: path.path())
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        cell.imageViewTappedDelegate = self
        cell.gestureRecognizers = []
        let imageTappedGesture = UITapGestureRecognizer(target: cell, action: #selector(cell.imageViewTapped))
        cell.imageView.addGestureRecognizer(imageTappedGesture)
        
        return cell
    }
    
    @objc func didImageViewTappedCell(cell: PersonCell) {
        editableCell = cell
        addOrEditPerson()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = peopleModel.people[indexPath.item]
        
        let ac = UIAlertController(title: "What do you want to do with \(person.name)?", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] _ in
            self?.presentRenameAlert(person: person)
        }))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.peopleModel.people.removeAll(where: { $0 == person })
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func presentRenameAlert(person: Person) {
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc func addOrEditPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        }
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editableCell = editableCell
        self.editableCell = nil
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName: String
        
        if let editableCell = editableCell, let person = editableCell.person {
            imageName = person.image
        } else {
            imageName = UUID().uuidString
        }
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            peopleModel.savePersonImage(imageName: imageName, imageData: jpegData)
        }
        
        if editableCell?.person == nil {
            let person = Person(name: "Unknown", image: imageName)
            peopleModel.people.append(person)
        }
        
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        editableCell = nil
        dismiss(animated: true)
    }
}
