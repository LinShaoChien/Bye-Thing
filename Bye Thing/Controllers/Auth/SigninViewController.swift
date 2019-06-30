//
//  SigninViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/28.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        signinWithEmailAndPassword()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        emailTextField.endEditing(true)
    }
    
    // MARK: - Create and add activity indicator to view
    func addActivityIndicator() {
        
        // Configure indicator
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = UIColor.lightGray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        
        // Configure indicator auto layout
        indicator.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerYConstraint = indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([
            centerXConstraint,
            centerYConstraint
            ])
        
    }
    
    func signinWithEmailAndPassword() {
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
        
        indicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                switch (error as NSError).code {
                case AuthErrorCode.wrongPassword.rawValue:
                    let alert = UIAlertController(title: "Wrong Email or Password", message: "Please refill email or password", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                case AuthErrorCode.invalidEmail.rawValue:
                    let alert = UIAlertController(title: "Invalid Email", message: "Email address is malformed", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "ok", style: .default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self.emailTextField.becomeFirstResponder()
                    })
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
                self.indicator.stopAnimating()
                return
            }
            self.indicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.endEditing(true)
            signinWithEmailAndPassword()
        }
        return true
    }
}
