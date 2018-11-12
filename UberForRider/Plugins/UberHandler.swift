//
//  UberHandler.swift
//  UberForRider
//
//  Created by Ajo M Varghese on 17/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import Foundation
import Firebase

protocol UberControllerDelegate: class {
    func canCallUber(delegateCalled: Bool);
    func driverAcceptedRide(driverName: String, rideAccepted: Bool);
    func updateDriverLocation(lat: Double, lon: Double);
}

class UberHandler {
    
    private static let _instance = UberHandler();
    
    static var Instance: UberHandler {
        return _instance;
    }
    
    weak var delegate: UberControllerDelegate?;
    
    var rider = "";
    var driver = "";
    var rider_id = "";
    
    func observeMessagesForRider() {
        // Requested Uber Ride
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key;
                        //print("The Request ID is: \(self.rider_id)")
                        self.delegate?.canCallUber(delegateCalled: true);
                    }
                }
            }
        }
        // Cancelled Uber Ride
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.delegate?.canCallUber(delegateCalled: false);
                    }
                }
            }
        }
        // Driver Accepts Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.driver == "" {
                        self.driver = name;
                        self.delegate?.driverAcceptedRide(driverName: name, rideAccepted: true);
                    }
                }
            }
        }
        // Driver Cancelled Uber
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = "";
                        self.delegate?.driverAcceptedRide(driverName: name, rideAccepted: false);
                    }
                }
            }
        }
        // Update Driver Location
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let lon = data[Constants.LONGITUTE] as? Double {
                                self.delegate?.updateDriverLocation(lat: lat, lon: lon);
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestUber(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: rider,
                                             Constants.LATITUDE: latitude,
                                             Constants.LONGITUTE: longitude];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data);
    }
    
    func cancelUber() {
        DBProvider.Instance.requestRef.child(rider_id).removeValue();
    }
    
    func updateRiderLocation(lat: Double, lon: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE : lat, Constants.LONGITUTE: lon]);
    }
} // Class
