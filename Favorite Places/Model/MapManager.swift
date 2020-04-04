//
//  MapManager.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 28.03.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import Foundation
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let mashtab = 1_000.00
    private var directionsArrays: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?

    
     func setupPlaceMark(place: Place, mapView: MKMapView) {
         
         guard let location = place.location else {return}
         
         let geocoder = CLGeocoder()
         geocoder.geocodeAddressString(location) { (placemarks, error) in
             
             if let error = error {
                 print(error)
                 return
             }
             
             
             guard let placemarks = placemarks else {return}
             
             let placemark = placemarks.first
             
             let annotation = MKPointAnnotation()
             annotation.title = place.name
             annotation.subtitle = place.type
             
             guard let placemarkLocation = placemark?.location else {return}
             
             annotation.coordinate = placemarkLocation.coordinate
             self.placeCoordinate = placemarkLocation.coordinate//передаём координаты свойству
             
             mapView.showAnnotations([annotation], animated: true)
             mapView.selectAnnotation(annotation, animated: true)
         }
     }
    
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse://когда используется геолокация
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied://отказано в доступе к геолокации
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Ваша локация недоступна", message: "Предоставьте доступ к вашей локации")
            }
            break
        case .notDetermined: //статус неопределён
            locationManager.requestWhenInUseAuthorization()// создаём запрос на выбор доступа к геолокации
            break
        case .restricted://если
            //alert
            break
        case .authorizedAlways:
            break
            
        @unknown default:
            print("new case is availble")
        }
    }
    
     func showUserLocation(mapView: MKMapView) {
           
           if let location = locationManager.location?.coordinate {//если получатся определить координаты
               
               let region = MKCoordinateRegion(center: location,
                                               latitudinalMeters: mashtab,
                                               longitudinalMeters: mashtab)
               mapView.setRegion(region, animated: true)
           }
       }
    
    
     func getDirecrion(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
            
            guard  let location = locationManager.location?.coordinate else {//извлекаем локацию пользователя
                showAlert(title: "Ошибка", message: "Локация неопределена")
                return
                
            }
            //после определения текущего местоположения пользователя включаем постоянное отслеживание положения пользователя
            locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))//запоминаем предыдущую локацию пользователя
            
            guard let request = createDirectionRequest(from: location) else {
                
                showAlert(title: "Ошибка", message: "Пункт назначения не найден")
                print("error")
                return
            }
            
            let direction = MKDirections(request: request)
            
        resetMapView(withNew: direction, mapView: mapView)//избавляемся от старых маршрутов
            
            direction.calculate { (response, error) in//расчитанные данные
                
                if let error = error {
                    print(error)
                    return
                }
                
                guard let response = response else {
                    
                    self.showAlert(title: "Ошибка", message: "Невозможно посмтроить маршрут")
                    return
                }
                
                for route in response.routes {//перебираем возможные маршруты
                    
                    mapView.addOverlay(route.polyline)//геометрия маршрута
                    mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)//отображение всего маршрута на карте (относительно геометрии маршрута)
                    
                    let distance = String(format: "%.1f", route.distance / 1000 )//округляем до десятков и переводим в километры
                    let timeInRoad = String(format: "%.1f", route.expectedTravelTime / 60 )//время в пути
                    
//                    self.timeInTheRoad.isHidden = false
//                    self.distanceInTheRoad.isHidden = false
//                    self.distanceInTheRoad.text = distance + "  км"
//                    self.timeInTheRoad.text = timeInRoad + "  мин"
    //                print("Расстояние до места: \(distance) км")
    //                print("Время в пути: \(timeInRoad)")
                }
            }
            
        }
    
     func createDirectionRequest(from coordinate: CLLocationCoordinate2D)
          -> MKDirections.Request? {//получаем координаты. возвращаем запрос
          
              guard let placeCoordinate = placeCoordinate else {return nil}//просто выйти нельзя. необходимо вернуть объект
              let startingLocation = MKPlacemark(coordinate: coordinate)
              let destination = MKPlacemark(coordinate: placeCoordinate)
              
              let request = MKDirections.Request()//позволяет определить точки начала и конца маршрута
              
              request.source = MKMapItem(placemark: startingLocation)//указываем стартовую точку
              request.destination = MKMapItem(placemark: destination)//и конечную
              request.transportType = .any//выбираем тип транспорта
              request.requestsAlternateRoutes = true//можно строить альтернативные маршурты, если они доступны
              return request
      }
    
    
     func startCheckngUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
           
           guard let location = location else {return}
           let center = getCenterLocation(for: mapView)
           guard center.distance(from: location) > 20 else { return }//если расстояние между новой точкой и старой больше 20 метров, то обновляем старую точку
        
            closure(center)
        
        
          // self.previousLocation = center
           //DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              // self.showUserLocation()
            
            

           //}
       }
    
    
     func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)//удаляем все текущие маршруты
        directionsArrays.append(directions)//массив маршрутов из параметра данного метода
        let _ = directionsArrays.map {$0.cancel()}//отменяем маршруты во всех элементах массива
        directionsArrays.removeAll()
    }
    
    
     func getCenterLocation(for mapView: MKMapView) -> CLLocation {//возвращаем координаты точки, находящейся по центру экрана
        
        let latitude = mapView.centerCoordinate.latitude//широта
        let longtitude = mapView.centerCoordinate.longitude//долгота
        
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
     func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        //проверяем доступность сервисов геопозиции
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest//точность определния геопозиции
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {//откладываем вызов alert
                self.showAlert(title: "Сервисы геолокации недоступны", message: "Активируйте службу геолокации")
            }
        }
    }
    
    
    
    private func showAlert(title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
