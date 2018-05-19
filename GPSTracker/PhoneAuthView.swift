//
//  PhoneAuthView.swift
//  GPSTracker
//
//  Created by Vitaly Usov on 11.05.2018.
//  Copyright © 2018 SomeCompany. All rights reserved.
//

import UIKit
import Firebase

class PhoneAuthView: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var codeField1: UITextField!
    @IBOutlet weak var codeField2: UITextField!
    @IBOutlet weak var codeField3: UITextField!
    @IBOutlet weak var codeField4: UITextField!
    @IBOutlet weak var codeField5: UITextField!
    @IBOutlet weak var codeField6: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var loadingSign: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        //CHANGE AUTH TO CHECK USER ON DIFFERENT VIEW OTHERWISE SKIPPING EMAIL ADDING
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                self.performSegue(withIdentifier: "toTrackigViewFromPhoneAuth", sender: nil)
            } else {
                // No user is signed in.
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorderTo(textField: phoneField)
        addBottomBorderTo(textField: codeField1)
        addBottomBorderTo(textField: codeField2)
        addBottomBorderTo(textField: codeField3)
        addBottomBorderTo(textField: codeField4)
        addBottomBorderTo(textField: codeField5)
        addBottomBorderTo(textField: codeField6)
        addBottomBorderTo(textField: emailField)
        codeField1.frame.origin.x += 400
        codeField2.frame.origin.x += 400
        codeField3.frame.origin.x += 400
        codeField4.frame.origin.x += 400
        codeField5.frame.origin.x += 400
        codeField6.frame.origin.x += 400
        emailField.frame.origin.x += 400
        emailField.isHidden = true
        submitButton.isHidden = true
        codeField1.delegate = self
        codeField2.delegate = self
        codeField3.delegate = self
        codeField4.delegate = self
        codeField5.delegate = self
        codeField6.delegate = self
        codeField1.isHidden = true
        codeField2.isHidden = true
        codeField3.isHidden = true
        codeField4.isHidden = true
        codeField5.isHidden = true
        codeField6.isHidden = true
        confirmButton.isHidden = true
        phoneField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1 ) && (string.count > 0) {
            if textField == codeField1 {
                codeField2.becomeFirstResponder()
            }
            
            if textField == codeField2 {
                codeField3.becomeFirstResponder()
            }
            
            if textField == codeField3 {
                codeField4.becomeFirstResponder()
            }
            
            if textField == codeField4 {
                codeField5.becomeFirstResponder()
            }
            
            if textField == codeField5 {
                codeField6.becomeFirstResponder()
            }
            
            if textField == codeField6 {
                codeField6.resignFirstResponder()
            }
            
            textField.text = string
            return false
        } else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            if textField == codeField2 {
                codeField1.becomeFirstResponder()
            }
            if textField == codeField3 {
                codeField2.becomeFirstResponder()
            }
            if textField == codeField4 {
                codeField3.becomeFirstResponder()
            }
            if textField == codeField5 {
                codeField4.becomeFirstResponder()
            }
            if textField == codeField6 {
                codeField5.becomeFirstResponder()
            }
            if textField == codeField1 {
                codeField1.resignFirstResponder()
            }
            
            textField.text = ""
            return false
        } else if (textField.text?.count)! >= 1 {
            textField.text = string
            return false
        }
        
        return true
    }
    
    func addBottomBorderTo(textField:UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if((phoneField.text?.isEmpty)!){
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
    
    @IBAction func tapSend(_ sender: Any) {
        sendButton.isHidden = true
        confirmButton.isHidden = false
        phoneField.isEnabled = false
        codeField1.isHidden = false
        codeField2.isHidden = false
        codeField3.isHidden = false
        codeField4.isHidden = false
        codeField5.isHidden = false
        codeField6.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.phoneField.frame.origin.x -= 400
            self.codeField1.frame.origin.x -= 400
            self.codeField2.frame.origin.x -= 400
            self.codeField3.frame.origin.x -= 400
            self.codeField4.frame.origin.x -= 400
            self.codeField5.frame.origin.x -= 400
            self.codeField6.frame.origin.x -= 400
        }, completion: nil)
        //phoneField.isHidden = true
        codeField1.becomeFirstResponder()
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneField.text!, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            // Sign in using the verificationID and the code sent to the user
            // ...
        }
    }
    
    @IBAction func tapConfirm(_ sender: Any) {
        loadingSign.startAnimating()
        confirmButton.isHidden = true
        let verificationCode = codeField1.text! + codeField2.text! + codeField3.text! + codeField4.text! + codeField5.text! + codeField6.text!
        print(verificationCode)
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                self.loadingSign.stopAnimating()
                //self.blurEffectView.isHidden = true
                return
            }else{
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        // User is signed in.
                        print("user created")
                        self.loadingSign.stopAnimating()
                        self.emailField.isHidden = false
                        self.submitButton.isHidden = false
                        UIView.animate(withDuration: 0.5, animations: {
                            self.emailField.frame.origin.x -= 400
                            self.codeField1.frame.origin.x -= 400
                            self.codeField2.frame.origin.x -= 400
                            self.codeField3.frame.origin.x -= 400
                            self.codeField4.frame.origin.x -= 400
                            self.codeField5.frame.origin.x -= 400
                            self.codeField6.frame.origin.x -= 400
                        }, completion: nil)
                        self.emailField.becomeFirstResponder()
                    } else {
                        // No user is signed in.
                    }
                }
            // User is signed in
            // ...
            }
        }
    }
    @IBAction func tapSubmit(_ sender: Any) {
        loadingSign.startAnimating()
        Auth.auth().currentUser?.updateEmail(to: emailField.text!) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                self.loadingSign.stopAnimating()
                return
            }else{
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        // User is signed in.
                        self.loadingSign.stopAnimating()
                        self.performSegue(withIdentifier: "toTrackigViewFromPhoneAuth", sender: nil)
                    } else {
                        // No user is signed in.
                    }
                }
            }
        }
    }
}
