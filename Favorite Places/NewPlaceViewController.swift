//
//  NewPlaceViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 24.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }
    
    //MARK: Table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alertController = UIAlertController(title: nil, message: nil,
                                                    preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Камера", style: .default) {_ in
                self.chooseImagePicker(source: .camera)
            }
            let photo = UIAlertAction(title: "Галерея", style: .default) {  _ in
                self.chooseImagePicker(source: .photoLibrary)

            }
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(camera)
            alertController.addAction(photo)
            alertController.addAction(cancel)
            present(alertController,animated: true)
        } else {
            view.endEditing(true)//скрываем клавиатуру
        }
    }
}
    // MARK: Text field delegate
    extension NewPlaceViewController: UITextFieldDelegate {
        //скрываем клавиатуру по нажатию на done
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
    }
//MARK: Work With Image
extension NewPlaceViewController { //выбор источника изображения
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
             let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true //редактирование изображений (например, масштаб)
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
}
