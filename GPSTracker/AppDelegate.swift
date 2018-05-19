//
//  AppDelegate.swift
//  GPSTracker
//
//  Created by Vitaly Usov on 04.05.2018.
//  Copyright © 2018 SomeCompany. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation //added

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var db: Firestore!
    
    struct data{
        var date: String
        var time: String
        var coordinates: String
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //UserDefaults.standard.set([data](), forKey: "data")
        let settings = FirestoreSettings()
        settings.areTimestampsInSnapshotsEnabled = true
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
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
            //var dataArray = UserDefaults.standard.array(forKey: "data") as! [data]
            var dataArray = [data]()
            let uid = UserDefaults.standard.value(forKey: "uid") as? String
            let email = UserDefaults.standard.value(forKey: "Email") as? String
            dataArray.append(data(date: todayD, time: nowT, coordinates: coords))
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    // User is signed in.
                    var ref: DocumentReference? = nil//to check error
                    ref = self.db.collection("tracking").addDocument(data: ["userID" : user.uid, "email" : user.email, "date" : todayD, "time" : nowT, "coordinates" : coords]){ err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            dataArray.removeLast()
                            if dataArray.isEmpty == false{
                                for element in dataArray{
                                    self.db.collection("tracking").addDocument(data: ["userID" : user.uid, "email" : user.email, "date" : element.date, "time" : element.time, "coordinates" : element.coordinates])
                                    dataArray.removeFirst()
                                }
                            }
                        }
                    }
                } else {
                    // No user is signed in.
                }
            }
            //UserDefaults.standard.set(dataArray, forKey: "data")
            dump(dataArray)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

