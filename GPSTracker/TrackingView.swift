//
//  TrackingView.swift
//  GPSTracker
//
//  Created by Vitaly Usov on 08.05.2018.
//  Copyright © 2018 SomeCompany. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class TrackingView: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var labelH: UILabel!
    @IBOutlet weak var labelU: UILabel!
    @IBOutlet weak var labelT: UILabel!
    
    var db: Firestore!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.set([String](), forKey: "coords")
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.labelU.text = user.email
                UserDefaults.standard.set(user.email, forKey: "Email")
                UserDefaults.standard.set(user.uid, forKey: "uid")
            } else {
                // No user is signed in.
            }
        }
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startMonitoringSignificantLocationChanges()
            self.locationManager.allowsBackgroundLocationUpdates = true
            }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print(location.coordinate)
            let coordlat = String(location.coordinate.latitude)
            let coordlong = String(location.coordinate.longitude)
            let coords = coordlat + ", " + coordlong
            let date = Date()
            let calender = Calendar.current
            let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let todayD = formatter.string(from: date)
            let nowT = String(components.hour!)  + ":" + String(components.minute!) + ":" +  String(components.second!)
            //var coordArray = UserDefaults.standard.array(forKey: "coords") as! [String]
            //coordArray.append(coords)
            
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    // User is signed in.
                    var ref: DocumentReference? = nil//to check error
                    ref = self.db.collection("tracking").addDocument(data: ["userID" : user.uid, "email" : user.email, "date" : todayD, "time" : nowT, "coordinates" : coords]){ err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            //coordArray.removeLast()
                        }
                    }
                } else {
                    // No user is signed in.
                }
            }
            //UserDefaults.standard.set(coordArray, forKey: "coords")
            //dump(coordArray)
        }
    }
    
    @IBAction func tapSignOut(_ sender: Any) {
        try! Auth.auth().signOut()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
            } else {
                // No user is signed in.
                self.performSegue(withIdentifier: "toSignInView", sender: nil)
            }
        }
    }
    
}
