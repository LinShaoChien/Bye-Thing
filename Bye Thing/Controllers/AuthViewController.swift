//
//  ViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/27.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
    
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
    }

    @IBAction func signUpPressed(_ sender: Any) {
        // Sign up
    }
    
    @IBAction func signinPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Segue.signin, sender: nil)
    }
    
    @IBAction func signinWithGmailPressed(_ sender: Any) {
        // Sign in with gmail
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
    
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            // Signup
        }
        return true
    }
    
}
