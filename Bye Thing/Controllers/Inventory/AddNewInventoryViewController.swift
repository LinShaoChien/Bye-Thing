//
//  AddNewInventoryViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/2.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddNewInventoryViewController: UIViewController {

    // MARK: - Subviews
    @IBOutlet weak var inventoryImageView: UIView!
    @IBOutlet weak var inventoryNameTextField: UITextField!
    @IBOutlet weak var inventoryTypeCollectionView: UICollectionView!
    @IBOutlet weak var inventoryDescriptionTextView: InventoryDescriptionTextView!
    @IBOutlet weak var selectPhotoIndicatorStackView: UIStackView!
    @IBOutlet weak var inventoryTypeCollectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            inventoryTypeCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: - Variables
    var indicator: UIActivityIndicatorView!
    var currentSelectedCellIndexPath: IndexPath?
    var keyboardHeight: CGFloat?
    var currentImage: UIImage?
    
    var currentInventory: Inventory?
    var didChangeInventoryImageInEditMode = false
    var isEditMode = false
    
    let imagePicker = UIImagePickerController()
    
    let inventoryTypes: [InventoryType] = [
        InventoryType(name: "Furniture"),
        InventoryType(name: "Electronics"),
        InventoryType(name: "Clothing"),
        InventoryType(name: "Shoes")
    ]
    
    // MARK: - View controller life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
        inventoryTypeCollectionView.delegate = self
        inventoryTypeCollectionView.dataSource = self
        inventoryDescriptionTextView.delegate = self
        imagePicker.delegate = self
        configureInventoryImageView()
        
        if isEditMode {
            titleLabel.text = "Edit Inventory"
            inventoryNameTextField.text = currentInventory!.name
            inventoryDescriptionTextView.text = currentInventory!.description
            inventoryDescriptionTextView.textColor = UIColor.black
            
            addImageToImageView()
            
            if let itemNumber = inventoryTypes.firstIndex(where: {$0.name == currentInventory!.type.name}) {
                let indexPath = IndexPath(row: itemNumber, section: 0)
                self.currentSelectedCellIndexPath = indexPath
                inventoryTypeCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            }
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - IBActions
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            
            // Check if the user did select/take an image
            guard let imageData = currentImage?.jpegData(compressionQuality: 1) else {
                let alert = UIAlertController(title: "Please select an image", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Check if user did give a name
            guard let name = inventoryNameTextField.text, inventoryNameTextField.text != "" else {
                let alert = UIAlertController(title: "Please Enter Item Name", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Check if user select an inventory type
            guard let indexPath = currentSelectedCellIndexPath else {
                let alert = UIAlertController(title: "Please Select Item Type", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Check if user write a description
            guard let description = inventoryDescriptionTextView.text, inventoryDescriptionTextView.text != "" || inventoryDescriptionTextView.text != "Description" else {
                let alert = UIAlertController(title: "Please Enter Item Description", message: nil
                    , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            indicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            if isEditMode {
                
                // First check if need to update photo
                if didChangeInventoryImageInEditMode {
                    // User did change inventory image
                    // Delete old Image
                    StorageServices.sharedInstance.delete(imageID: self.currentInventory!.imageID) { (error) in
                        // Handle error
                    }
                    
                    // Upload new image
                    let randomImageID = UUID().uuidString
                    StorageServices.sharedInstance.upload(data: imageData, withName: randomImageID + ".jpeg", inChild: "images") { (success, error) in
                        if success {
                            
                            // Finally update inventory
                            let itemType = self.inventoryTypes[indexPath.row].name
                            let date = Date()
                            
                            FirestoreServices.sharedInstance.updateInventory(uid: uid, id: self.currentInventory!.id, imageID: randomImageID, itemName: name, itemType: itemType, itemDescription: description, lastModifyTime: date, completion: { (success, error) in
                                if success {
                                    NotificationCenter.default.post(name: NSNotification.Name("didAddNewInventory"), object: nil)
                                    self.indicator.stopAnimating()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    /// Handle error
                                    self.indicator.stopAnimating()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                            })
                            
                        } else {
                            /// Handle error
                            self.indicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    }
                } else {
                    // User did not change inventory image
                    // Update inventory
                    let itemType = self.inventoryTypes[indexPath.row].name
                    let date = Date()
                    
                    FirestoreServices.sharedInstance.updateInventory(uid: uid, id: self.currentInventory!.id, imageID: nil, itemName: name, itemType: itemType, itemDescription: description, lastModifyTime: date, completion: { (success, error) in
                        if success {
                            NotificationCenter.default.post(name: NSNotification.Name("didAddNewInventory"), object: nil)
                            self.indicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            /// Handle error
                            self.indicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    })
                }
                
            } else {
                // Not in edit mode, create inventory
                // Give selected image a random id and upload it to firebase storage
                let randomImageID = UUID().uuidString
                StorageServices.sharedInstance.upload(data: imageData, withName: randomImageID + ".jpeg", inChild: "images") { (success, error) in
                    if success {
                        
                        // Finally create an inventory in the firebase db
                        let itemType = self.inventoryTypes[indexPath.row].name
                        let date = Date()
                        FirestoreServices.sharedInstance.createInventory(uid: uid, imageID: randomImageID, itemName: name, itemType: itemType
                        , itemDescription: description, lastModifyTime: date) { (success, error) in
                            if success {
                                NotificationCenter.default.post(name: NSNotification.Name("didAddNewInventory"), object: nil)
                                self.indicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                /// Handle error
                                self.indicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        }
                    } else {
                        /// Handle error
                        self.indicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                }
            }
        }
        
    }
    
    // MARK: -
    private func addActivityIndicator() {
        
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
    
    // MARK: -
    private func configureInventoryImageView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.chooseImagePickerType(_:)))
        inventoryImageView.addGestureRecognizer(tap)
    }
    
    // MARK: -
    private func addImageToImageView() {
        let image = currentInventory!.image
        let size = CGSize(width: self.inventoryImageView.bounds.width, height: self.inventoryImageView.bounds.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        currentImage = resizedImage
        self.inventoryImageView.backgroundColor = UIColor(patternImage: resizedImage)
        self.selectPhotoIndicatorStackView.isHidden = true
        
    }

    // MARK: -
    @objc func chooseImagePickerType(_ recognizer: UIGestureRecognizer) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let selectFromAlbumAction = UIAlertAction(title: "Select From Album", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
        }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(selectFromAlbumAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }

    
}

extension AddNewInventoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventoryTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inventoryTypeCell", for: indexPath) as! InventoryTypeCollectionViewCell
        let typeName = inventoryTypes[indexPath.item].name
        cell.configureCell(typeName: typeName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InventoryTypeCollectionViewCell
        currentSelectedCellIndexPath = indexPath
        cell.setStyle()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InventoryTypeCollectionViewCell
        cell.setStyle()
    }
    
    
}

extension AddNewInventoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: self.inventoryImageView.bounds.width, height: self.inventoryImageView.bounds.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        self.currentImage = resizedImage
        if isEditMode {
            self.didChangeInventoryImageInEditMode = true
            self.inventoryImageView.backgroundColor = UIColor(patternImage: resizedImage)
        } else {
            self.inventoryImageView.backgroundColor = UIColor(patternImage: resizedImage)
            self.selectPhotoIndicatorStackView.isHidden = true
        }
        
    }
    

}

extension AddNewInventoryViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGray
            textView.text = "Description"
        }
        
    }
}
