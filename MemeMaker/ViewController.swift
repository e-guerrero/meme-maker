//
//  ViewController.swift
//  MemeMaker
//
//  Created by Edwin Guerrero on 9/23/20.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: Float(5)
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        // disable the camera if the device being used doesn't have one.
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        // couldn't get the alignment attribute working as an NSAttributedString.
        // - try finding a subclass that has these attributes
        //      and then replace [NSAttributedString.Key: Any] with ["subclass": Any],
        // - else replace [NSAttributedString.Key: Any] with [String: Any].
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        // find out how to capitalize all characters. this one doesn't seem to do it.
        topTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
    }

    @IBAction func pickAnImageFromPhotoLibrary(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageKey = UIImagePickerController.InfoKey.originalImage
        if let image =  info[imageKey] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

