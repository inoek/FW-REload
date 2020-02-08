//
//  Place.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 23.01.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import RealmSwift

class Place: Object {

    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0//double

    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {//инициализатор модели
        self.init()//вызываем инициализатор класса
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }

}





