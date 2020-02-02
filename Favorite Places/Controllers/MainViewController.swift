//
//  MainViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 23.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    

    var places: Results<Place>!//results - объект realm. В квадратных скобках указываем имя модели. Возвращает контент в реальном времени. Это как массив
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)//модель

    }

//     MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return places.isEmpty ? 0 : places.count //если пустой, то возвращаем 0, иначе ёмкость массива
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row] //ссылка на массив

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlaces.image = UIImage(data: place.imageData!)



        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    //MARK Table View Delegate

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let delete = UIContextualAction(style: .normal, title: "Удалить") { (_, _, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = .systemRed

               return UISwipeActionsConfiguration(actions: [delete])
    }
    

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPLaceVC = segue.source as? NewPlaceViewController else {return}
        newPLaceVC.saveNewPlace()
        
        tableView.reloadData()
    }
    
}
