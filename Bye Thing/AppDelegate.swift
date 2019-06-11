//
//  AppDelegate.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/27.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth
import FBSDKCoreKit
import IQKeyboardManagerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if let window = self.window {
            if Auth.auth().currentUser == nil {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let authViewController = storyboard.instantiateViewController(withIdentifier: "signupViewController") as! AuthViewController
                window.rootViewController = authViewController
            } else {
                let storyboard = UIStoryboard(name: "Inventory", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
                window.rootViewController = mainTabBarController
            }
            
        }
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let wasHandled = ApplicationDelegate.shared.application(app, open: url, options: options)
        if wasHandled == true {
            return wasHandled
        }
        
        return GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                switch (error as NSError).code {
                case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                    
                    // Fetch sign in methods for email, and prompt user to sign in with the previous method
                    Auth.auth().fetchSignInMethods(forEmail: user.profile.email, completion: { (methods, error) in
                        if let error = error {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                            alert.addAction(alertAction)
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        } else {
                            if let methods = methods {
                                print(methods.first as Any)
                            }
                        }
                    })
                default: return
                }
                return
            }
            
            // Do something after the user is sign in
            if let authResult = authResult {
                if authResult.additionalUserInfo!.isNewUser {
                    let uid = authResult.user.uid
                    if let email = authResult.user.email {
                        FirestoreServices.sharedInstance.createUser(uid: uid, email: email)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
}

