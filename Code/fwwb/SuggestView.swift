//
//  SuggestVirew.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/3.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class SuggestView: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var Contact: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0: return 2
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }
    
    @IBOutlet var Context: UITextView!
    @IBOutlet var Image: UIButton!
    

    @IBAction func ChangeImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: {
            self.Image.setImage(image, for: .normal)
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!(indexPath.section == 0 && indexPath.row == 0)){
            Context.resignFirstResponder()
        }
        if(!(indexPath.section == 1)){
            Contact.resignFirstResponder()
        }
        if(indexPath.section == 2 && indexPath.row == 0){
            switch(UserDefaults.standard.string(forKey: "language")){
            
            case "zh-Hans-US":
                let alertController = UIAlertController(title: "提交成功", message: "感谢您的反馈", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                present(alertController, animated: true)
            case "ja-US":
                let alertController = UIAlertController(title: "提出の成功", message: "フィードバックありがとうございます", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
                present(alertController, animated: true)
            default:
                let alertController = UIAlertController(title: "提交成功", message: "感谢您的反馈", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                present(alertController, animated: true)
            }
        }
    }
    
    
    
}
