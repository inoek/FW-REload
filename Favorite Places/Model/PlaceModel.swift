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

    convenience init(name: String, location: String?, type: String?, imageData: Data?) {//инициализатор модели
        self.init()//вызываем инициализатор класса
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }

}





