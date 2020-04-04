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

let mapManager = MapManager()
var mapViewControllerDelegate: MapViewControllerDelegate?
var place = Place()

let annotationIdentifier = "annotationIdentifier"
var incomeSegueIdentifier = ""

var previousLocation: CLLocation? {
    didSet {
        mapManager.startCheckngUserLocation(
            for: mapView,
            and: previousLocation) { (currentLocation) in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
        }
    }
}


@IBOutlet var mapPinImage: UIImageView!
@IBOutlet var mapView: MKMapView!
@IBOutlet var currentAddress: UILabel!
@IBOutlet var doneButton: UIButton!
@IBOutlet var directionButton: UIButton!
@IBOutlet var timeOnTheRoad: UILabel!
@IBOutlet var distanceOnTheRoad: UILabel!

override func viewDidLoad() {
    super.viewDidLoad()
    //mapView.delegate = self
    timeOnTheRoad.isHidden = true
    distanceOnTheRoad.isHidden = true
    currentAddress.text = ""
    setupMapView()
    // Do any additional setup after loading the view.
}

@IBAction func closeVC(_ sender: Any) {
    
    dismiss(animated: true)
}



@IBAction func lookingUserAtTheMap() {
    mapManager.showUserLocation(mapView: mapView)
}

@IBAction func doneButtonPressed() {
    
    mapViewControllerDelegate?.getAdress(currentAddress.text)//при нажатии на кнопку done передаём адрес в label. затем закрываем контроллер?
    dismiss(animated: true)
}
@IBAction func directionButtonPressed() {
    
    mapManager.getDirecrion(for: mapView) { (location) in
        self.previousLocation = location
    }
}

private func setupMapView() {
    
    directionButton.isHidden = true
    
    mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
        mapManager.locationManager.delegate = self
    }
    
    if incomeSegueIdentifier == "showCurrentPlace" {
        mapManager.setupPlaceMark(place: place, mapView: mapView)
        mapPinImage.isHidden = true
        currentAddress.isHidden = true
        doneButton.isHidden = true
        directionButton.isHidden = false
    }
}










//private func setupLocationManager() {
//    locationManager.delegate = self
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest
//}


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
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()//преобразовывает координаты в адрес и наоборот
        
        if incomeSegueIdentifier == "showCurrentPlace" && previousLocation != nil {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()//отмена запроса
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {//отображаем маршрут на карте
        
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)//ренедрим наложение
        render.strokeColor = .blue//красим в цвет
        
        return render
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
