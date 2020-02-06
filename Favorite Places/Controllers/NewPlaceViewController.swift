//
//  NewPlaceViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 24.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var imageIsChanged = false
    var currentPlace: Place?
    

    
    @IBOutlet var placeImage: UIImageView!
    
    @IBOutlet var placeName: UITextField!
    
    @IBOutlet var placeLocation: UITextField!
    
    @IBOutlet var placeType: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)//при редактировании поля срабатывает и вызывает textFieldChanged
        
        setupEditScreen()
        
        
        //        DispatchQueue.main.async {
        //            self.newPlace.savePlaces()
        //        }
        
        
    }
    
    
    //MARK: Table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let alertController = UIAlertController(title: nil, message: nil,
                                                    preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Камера", style: .default) {_ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photo = UIAlertAction(title: "Галерея", style: .default) {  _ in
                self.chooseImagePicker(source: .photoLibrary)
                
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            
            alertController.addAction(camera)
            alertController.addAction(photo)
            alertController.addAction(cancel)
            
            present(alertController,animated: true)
        } else {
            view.endEditing(true)//скрываем клавиатуру
        }
    }
                func savePlace() {
        
        
        var image: UIImage?
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        let imageData = image?.pngData()//конвентируем image to imageData
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData)
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    //    func saveNewPlace() {
    //
    //        var image: UIImage?
    //
    //        if imageIsChanged {
    //            image = placeImage.image
    //        } else {
    //            image = #imageLiteral(resourceName: "imagePlaceholder")
    //        }
    //
    //        let imageData = image?.pngData()
    //
    //        let newPlace = Place(name: placeName.text!,
    //                             location: placeLocation.text,
    //                             type: placeType.text,
    //                             imageData: imageData)
    //
    //        if currentPlace != nil {
    //            try! realm.write {
    //                currentPlace?.name = newPlace.name
    //                currentPlace?.location = newPlace.location
    //                currentPlace?.type = newPlace.type
    //                currentPlace?.imageData = newPlace.imageData
    //            }
    //        } else {
    //            StorageManager.saveObject(newPlace)
    //        }
    //    }
    private func setupEditScreen() {
        
        
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
        }
    }
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        if currentPlace?.name != "" {
            saveButton.isEnabled = true
        }
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: Text field delegate
extension NewPlaceViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChanged() { //проверяем заполненность поля name
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
    
    
    
}
//MARK: Work With Image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,//добавляем изображение
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleToFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}

