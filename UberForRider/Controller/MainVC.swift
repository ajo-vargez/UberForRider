//
//  MainVC.swift
//  UberForRider
//
//  Created by Ajo M Varghese on 12/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MainVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberControllerDelegate {

    // MARK : - Declaration
    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var uberButton: UIButton!;
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var driverLocation: CLLocationCoordinate2D?;
    
    private var timer = Timer();
    private var canCallUber = true;
    private var riderCancelledUber = false;
    
    @IBAction func signOut(_ sender: AnyObject) {
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancelUber();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            alertUser(title: "Problem Logging Out", message: "Could not logOut at the moment, Please try after sometime");
        }
    }
    
    @IBAction func callUber(_ sender: AnyObject) {
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude));
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(60), target: self, selector: #selector(MainVC.updateLocation), userInfo: nil, repeats: true);
            } else {
                riderCancelledUber = true;
                UberHandler.Instance.cancelUber();
                timer.invalidate();
            }
        }
    }
    
    // MARK : - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initializeLocationManager();
        UberHandler.Instance.observeMessagesForRider();
        UberHandler.Instance.delegate = self;
    }
    
    // MARK : - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            mapView.setRegion(region, animated: true);
            
            mapView.removeAnnotations(mapView.annotations);
            
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation = MKPointAnnotation();
                    driverAnnotation.coordinate = driverLocation!;
                    driverAnnotation.title = "Driver's Location";
                    mapView.addAnnotation(driverAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Rider's Location";
            mapView.addAnnotation(annotation);
        }
    }
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            uberButton.setTitle("Cancel UBER", for: UIControl.State.normal);
            canCallUber = false;
        } else {
            uberButton.setTitle("Call UBER", for: UIControl.State.normal);
            canCallUber = true;
        }
    }
    
    func driverAcceptedRide(driverName: String, rideAccepted: Bool) {
        if !riderCancelledUber {
            if rideAccepted {
                alertUser(title: "Uber Accepted", message: "\(driverName) has accepted your ride");
            } else {
                UberHandler.Instance.cancelUber();
                timer.invalidate();
                alertUser(title: "Uber Cancelled", message: "\(driverName) has cancelled the ride");
            }
        }
        riderCancelledUber = false;
    }
    
    func updateDriverLocation(lat: Double, lon: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon);
    }
    
    // MARK : - User/Custom Methods
    func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    @objc func updateLocation() {
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, lon: userLocation!.longitude);
    }

    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
} // Class
