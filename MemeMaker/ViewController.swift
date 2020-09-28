//
//  ViewController.swift
//  MemeMaker
//
//  Created by Edwin Guerrero on 9/23/20.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Issue: The text fill is clear instead of white. The attribute for it here won't work, nor on storyboard.
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
//        NSAttributedString.Key.strokeWidth: Float(5),
//        NSAttributedString.Key.strokeColor: UIColor.black,
//        NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    var memeImage: UIImage!
    var meme: Meme!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        // disable the camera if the device being used doesn't have one
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        // disable the share button to prevent user from sharing an unfinished meme
        shareButton.isEnabled = false
        // have the keyboard notify when it will show/hide
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Issue: couldn't get the alignment attribute working as an NSAttributedString.
        // - try finding a subclass that has these attributes
        //      and then replace [NSAttributedString.Key: Any] with ["subclass": Any],
        // - else replace [NSAttributedString.Key: Any] with [String: Any].
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        // find out how to capitalize all characters. this one doesn't seem to do it.
        topTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // unsubscribe from being notified when the keyboard appears
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Present and Pick Image

    @IBAction func pickAnImageFromCameraRoll(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePictureWithCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Dismiss and Set Image
    
    // Issue: if you select a text field, press the camera roll or camera button, and then
    //  pick an image or click cancel, the text fields disappear.
    // - try to keep the toolbar covered when the keyboard shows
    //      by using toolbar.isHidden()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imageKey = UIImagePickerController.InfoKey.originalImage
        if let image =  info[imageKey] as? UIImage {
            imageView.image = image
        }
        save() // the meme
        shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // Issue: image picker still dismisses after it's canceled even if this method is removed.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Show
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    // Hide
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Subscribe
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Meme
    
    func generateMemedImage() -> UIImage {
        toolbar.isHidden = true
        navigationBar.isHidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolbar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        // create the meme
        memeImage = generateMemedImage()
        meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image!, memeImage: memeImage!)
    }
    
    @IBAction func share(_ sender: Any) {
        // generate a memed image
        let memedImage = generateMemedImage()
        // define an instance of the ActivityViewController and pass the ActivityViewController a
        //  memedImage as an activity item.
        let avc = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // save the meme
        avc.completionWithItemsHandler = { activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        // present the ActivityController
        present(avc, animated: true)
    }
    
}

