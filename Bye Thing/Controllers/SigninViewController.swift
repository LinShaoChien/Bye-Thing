//
//  SigninViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/28.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func signinButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        emailTextField.endEditing(true)
    }
    
    

}
