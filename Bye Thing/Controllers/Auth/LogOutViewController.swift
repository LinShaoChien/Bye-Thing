//
//  LogOutViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/2.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogOutViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let authVC = storyboard.instantiateViewController(withIdentifier: "signupViewController") as! AuthViewController
                self.present(authVC, animated: true, completion: nil)
            } else {
                self.emailLabel.text = user!.email
            }
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    @IBAction func logoutPressed(_ sender: Any) {
        try! Auth.auth().signOut()
    }
}
