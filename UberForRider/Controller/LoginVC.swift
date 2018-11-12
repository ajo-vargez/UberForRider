//
//  LoginVC.swift
//  UberForRider
//
//  Created by Ajo M Varghese on 10/09/18.
//  Copyright © 2018 Ajo M Varghese. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    // MARK : - Declaration
    @IBOutlet weak var emailText: UITextField!;
    @IBOutlet weak var passwordText: UITextField!;
    
    private let TO_MAIN_SEGUE = "toMain";
    
    @IBAction func signIn (_ sender: AnyObject) {
        if emailText.text != "" && passwordText.text != "" {
            AuthProvider.Instance.logIn(withEmail: emailText.text!, password: passwordText.text!) { (message) in
                if message != nil {
                    self.alertUser(title: "Problem With Authentication", message: message!);
                } else {
                    UberHandler.Instance.rider = self.emailText.text!;
                    
                    self.emailText.text = "";
                    self.passwordText.text = "";
                    
                    self.performSegue(withIdentifier: self.TO_MAIN_SEGUE, sender: nil);
                }
            }
        } else {
            alertUser(title: "Email and Password are Required", message: "Please enter both email ID and password");
        }
    }
    
    @IBAction func signUp (_ sender: AnyObject) {
        if emailText.text != "" && passwordText.text != "" {
            AuthProvider.Instance.register(withEmail: emailText.text!, password: passwordText.text!) { (message) in
                if message != nil {
                    self.alertUser(title: "Problem With Registering New Account", message: message!);
                } else {
                    UberHandler.Instance.rider = self.emailText.text!;
                    
                    self.emailText.text = "";
                    self.passwordText.text = "";
                    
                    self.performSegue(withIdentifier: self.TO_MAIN_SEGUE, sender: nil);
                }
            }
        } else {
            alertUser(title: "Email and Password are Required", message: "Please enter both email ID and password");
        }
    }
    
    // MARK : - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad();

        
    }
    
    // MARK : - User/Custom Methods
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert);
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
} // Class
