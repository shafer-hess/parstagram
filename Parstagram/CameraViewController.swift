//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Shafer Hess on 2/17/20.
//  Copyright © 2020 Shafer Hess. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // CameraViewController Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        // Create Parse Post Object
        let post = PFObject(className: "Posts")
        
        // Define columns of post object
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        // Retrieve Image Data and Save it to Post Column
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        post["image"] = file
        
        // Save Post to Parse Database
        post.saveInBackground { (success, error) in
            if(success) {
                // Dismiss CameraViewController
                self.dismiss(animated: true, completion: nil)
                
            } else {
                print("Error uploading post: \(error?.localizedDescription ?? "Error Uploading")")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true

        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                picker.sourceType = .camera
        } else {
                picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Retrieve selected image from camera
        let image = info[.editedImage] as! UIImage
        
        // Scale Image to reduce size for database
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        // Resize ImageView to match 300x300 image
        imageView.frame = CGRect(x: imageView.frame.midX - imageView.frame.height / 2, y: imageView.frame.midY - imageView.frame.height / 2, width: imageView.frame.height, height: imageView.frame.height)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapBackground(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
