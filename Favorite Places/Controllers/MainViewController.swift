//
//  MainViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 23.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    

    var places = Place.getPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = places[indexPath.row] //ссылка на массив
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        
        
        if place.image == nil {
             
        cell.imageOfPlaces.image = UIImage(named: place.restarauntImage!)
        } else {
            cell.imageOfPlaces.image = place.image
        }
        
        cell.imageOfPlaces.layer.cornerRadius = cell.imageOfPlaces.frame.size.height / 2
        cell.imageOfPlaces.clipsToBounds = true
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPLaceVC = segue.source as? NewPlaceViewController else {return}
        newPLaceVC.saveNewPlace()
        places.append(newPLaceVC.newPlace!)
        tableView.reloadData()
    }
    
}
