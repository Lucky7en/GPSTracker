//
//  SignInView.swift
//  GPSTracker
//
//  Created by Vitaly Usov on 04.05.2018.
//  Copyright © 2018 SomeCompany. All rights reserved.
//

import UIKit
import Firebase

class SignInView: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var loadingSign: UIActivityIndicatorView!
    
    var blurEffectView = UIVisualEffectView()
    
    override func viewWillAppear(_ animated: Bool) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(loadingSign)
        blurEffectView.isHidden = true
        
        if((emailField.text?.isEmpty)! || (passField.text?.isEmpty)!){
        signinButton.isEnabled = false
        createButton.isEnabled = false
        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.performSegue(withIdentifier: "toTrackigView", sender: nil)
            } else {
                // No user is signed in.
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if((emailField.text?.isEmpty)! || (passField.text?.isEmpty)!){
            signinButton.isEnabled = false
            createButton.isEnabled = false
        }else{
            signinButton.isEnabled = true
            createButton.isEnabled = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapCreateAccount(_ sender: Any) {
        loadingSign.startAnimating()
        blurEffectView.isHidden = false
        Auth.auth().createUser(withEmail: emailField.text!, password: passField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                self.loadingSign.stopAnimating()
                self.blurEffectView.isHidden = true
                return
            }else{
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        // User is signed in.
                        print("\(user.email!) created")
                        self.loadingSign.stopAnimating()
                    } else {
                        // No user is signed in.
                    }
                }
            }
        }
    }
    
    
    @IBAction func tapSignIn(_ sender: Any) {
        loadingSign.startAnimating()
        blurEffectView.isHidden = false
        Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                self.loadingSign.stopAnimating()
                self.blurEffectView.isHidden = true
                return
            }else{
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        // User is signed in.
                        print("\(user.email!) signed in")
                        self.loadingSign.stopAnimating()
                    } else {
                        // No user is signed in.
                    }
                }
            }
        }
    }
    
}
