//
//  MapViewController.swift
//  Favorite Places
//
//  Created by Игорь Ноек on 09.02.2020.
//  Copyright © 2020 Игорь Ноек. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

 protocol MapViewControllerDelegate {
   //@objc to protocol; @objc optional to body
   func getAdress(_ adress: String?) //оциональная функция
    
    
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()//инициализируем значения по-умолчанию
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let mashtab = 1_000.00
    var currentSegueIdentifier = ""
    
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currentAddress: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView.delegate = self
        currentAddress.text = ""
        setupMapView()
        checkLocationServices()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeVC(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    
    @IBAction func lookingUserAtTheMap() {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        
        mapViewControllerDelegate?.getAdress(currentAddress.text)//при нажатии на кнопку done передаём адрес в label. затем закрываем контроллер?
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        if currentSegueIdentifier == "showCurrentPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            currentAddress.isHidden = true
            doneButton.isHidden = true
        }
    }
    private func setupPlaceMark() {
        
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
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        //проверяем доступность сервисов геопозиции
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {//откладываем вызов alert
                self.showAlert(title: "Сервисы геолокации недоступны", message: "Активируйте службу геолокации")
            }
        }
    }
    
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse://когда используется геолокация
            mapView.showsUserLocation = true
            if currentSegueIdentifier == "getAddress" { showUserLocation() }
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
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {//если получатся определить координаты
            
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: mashtab,
                                            longitudinalMeters: mashtab)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {//возвращаем координаты точки, находящейся по центру экрана
        
        let latitude = mapView.centerCoordinate.latitude//широта
        let longtitude = mapView.centerCoordinate.longitude//долгота
        
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
    
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotaionView == nil {
            annotaionView = MKPinAnnotationView(annotation: annotation,
                                                reuseIdentifier: annotationIdentifier)
            annotaionView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotaionView?.rightCalloutAccessoryView = imageView
        }
        
        return annotaionView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {//оторбражается при смене отображаемого региона
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()//преобразовывает координаты в адрес и наоборот
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first//извлекаем первый элемент из массива
            let streetName = placemark?.thoroughfare
            let builtNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && builtNumber != nil {
                    self.currentAddress.text = "\(streetName!), \(builtNumber!)"
                } else if streetName != nil {
                    self.currentAddress.text = "\(streetName!)"
                } else{
                    self.currentAddress.text = ""
                }
                
            }
            
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
