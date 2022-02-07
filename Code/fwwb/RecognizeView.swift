//
//  Recognize.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/19.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class RecognizeView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()
    
    var origin_up: CGPoint!
    var origin_down: CGPoint!
    
    @IBOutlet var img_up: UIImageView!
    @IBOutlet var img_down: UIImageView!
    @IBOutlet var camera: UIButton!
    @IBOutlet var photolib: UIButton!
    
    var image: UIImage? = nil
    
    @IBAction func Camera(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    @IBAction func Photolib(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "ShowRecognizeResult", sender: self.image)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowRecognizeResult"){
            let controller = segue.destination as! RecognizeDoneView
            controller.image = sender as? UIImage
        }
    }
    
    @IBAction func Back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if(origin_up == nil){
            origin_up = img_up.center
            origin_down = img_down.center
            
            camera.isHidden = true
            photolib.isHidden = true
            img_up.center = origin_up
            img_down.center = origin_down
            
            
            UIView.animate(withDuration: 1, delay: 0, animations: {
                self.img_up.center.y -= 100
                self.img_down.center.y += 100
                
            }, completion: { _ in
                self.camera.isHidden = false
                self.photolib.isHidden = false
            })
        }
        
    }
    
    
    
    @IBOutlet var RecognizeNavigationItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.isHidden = true
        photolib.isHidden = true
        
        title = {
            switch(UserDefaults.standard.string(forKey: "language")){
            case "zh-Hans-US": return "景点识别"
            case "ja-US": return "スポット認識"
            default: return "景点识别"
            }
        }()
    }
}
