//
//  StorageManager.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 02.02.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//
//
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
