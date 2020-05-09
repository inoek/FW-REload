//
//  MainViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 23.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil)//nil - означает, что поиск будет происходить на том же view, где и располагается основной контент
    private var ascSorting = true
    private let segueIdentifyForEdit = "showDetail"
    private var places: Results<Place>!//results - объект realm. В квадратных скобках указываем имя модели. Возвращает контент в реальном времени. Это как массив
    private var filteredPLaces: Results<Place>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
            return text.isEmpty

    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    

    
    @IBOutlet var tableView: UITableView!
   
    
    @IBOutlet var segmentendControl: UISegmentedControl!
    
    @IBOutlet var reversedSortButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)//модель
        //настройка searchController
        searchController.searchResultsUpdater = self //получателем информации о поиске будет наш класс
        searchController.obscuresBackgroundDuringPresentation = false //отключение данного параметра позволяет пользоваться view с результатами, как с основным (можно его редактировать)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController //интегрируем поиск в navigation bar
        definesPresentationContext = true //отпускаем строку поиска при переходе на другой экран
    }
    
    //     MARK: - Table view data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPLaces.count
        } else {
        return places.isEmpty ? 0 : places.count //если пустой, то возвращаем 0, иначе ёмкость массива
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        //let place = places[indexPath.row] //ссылка на массив
        var place = Place()
        
        cell.backgroundColor = .clear
                
        if isFiltering {
            place = filteredPLaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        cell.nameLabel.text = "Название:   " + place.name
        
        if place.location != "" {
       cell.locationLabel.text = "Адрес:   " + place.location!
        } else {
            cell.locationLabel.text = ""
        }
        
        if place.type != "" {
        cell.definisionLabel.text = "Описание:   " + place.type!
        } else {
            cell.definisionLabel.text = ""
        }
        
        cell.imageOfPlaces.image = UIImage(data: place.imageData!)
        
        
        
        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true
        cell.imageOfPlaces.contentMode = .scaleToFill
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    //MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let delete = UIContextualAction(style: .normal, title: "Удалить") { (_, _, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifyForEdit {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering {
                place = filteredPLaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPLaceVC = segue.destination as! NewPlaceViewController
            newPLaceVC.currentPlace = place//передаём объект с типом place на NewPlaceViewController
        }
        
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPLaceVC = segue.source as? NewPlaceViewController else {return}
        newPLaceVC.savePlace()
        
        tableView.reloadData()
    }
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date")
        } else {
            places = places.sorted(byKeyPath: "name")
        }
        
        tableView.reloadData()
    }
    @IBAction func reverseSorting(_ sender: UIBarButtonItem) {
        
        ascSorting.toggle()
        
        if ascSorting {
            reversedSortButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
   private func sorting() {
          if segmentendControl.selectedSegmentIndex == 0 {
              places = places.sorted(byKeyPath: "date", ascending: ascSorting)
          } else {
              places = places.sorted(byKeyPath: "name", ascending: ascSorting)
          }
          tableView.reloadData()
      }
    
}


extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPLaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText )
        tableView.reloadData()
    }

}

