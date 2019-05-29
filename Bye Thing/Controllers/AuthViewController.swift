//
//  ViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/27.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class AuthViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Segue
    enum Segue {
        static let signin = "toSignin"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGestureRecognizer()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }

    @IBAction func signUpPressed(_ sender: Any) {
        createUser()
    }
    
    @IBAction func signinPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Segue.signin, sender: nil)
    }
    
    @IBAction func signinWithGooglePressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func signinWithFacebookPressed(_ sender: Any) {
        // Sign in with facebook
    }
    
    private func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ recognizer: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func createUser() {
        guard let email = emailTextField.text, emailTextField.text != "" else {
            let alert = UIAlertController(title: "Email must not be empty.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            emailTextField.becomeFirstResponder()
            return
        }
        
        guard let password = passwordTextField.text, passwordTextField.text != "" else {
            let alert = UIAlertController(title: "Password must not be empty.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            passwordTextField.becomeFirstResponder()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard error == nil else {
                
                switch (error! as NSError).code {
                case AuthErrorCode.invalidEmail.rawValue:
                    let alert = UIAlertController(title: "Invalid Email", message: "Email address is malformed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    let alert = UIAlertController(title: "Email Already In Use", message: "Please sign in or select another email", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                case AuthErrorCode.weakPassword.rawValue:
                    if let message = (error! as NSError).userInfo["NSLocalizedDescription"] {
                        let alert = UIAlertController(title: "Weak Password", message: "\(message)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                case AuthErrorCode.operationNotAllowed.rawValue:
                    let alert = UIAlertController(title: "Email Not Allowed", message: "This email is not allowed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                default:
                    return
                }
                return
            }
            print("CREATE USER!")
        }
    }
    
    
    
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            createUser()
        }
        return true
    }
    
}

