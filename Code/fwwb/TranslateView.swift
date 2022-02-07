//
//  TranslateView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/14.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class TranslateView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var source: UITextView!
    @IBOutlet var destination: UITextView!
    @IBOutlet var language: UISegmentedControl!
    
    var image:UIImage? = nil
    
    
    @IBAction func PhotoTranslate(_ sender: Any) {
        self.present(selectController, animated: true)
    }
    
    
    //底部提示框
    var selectController: UIAlertController{
        let controller = UIAlertController(title : nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "相册选择", style: .default){
            action in self.selectorSourceType(type: .photoLibrary)
        })
        controller.addAction(UIAlertAction(title: "拍照", style: .default){
            action in self.selectorSourceType(type: .camera)
        })
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: 0,y: 0,width: 1.0,height: 1.0)
        }
        return controller
    }
    
    //相册或拍照的分支选择
    func selectorSourceType(type: UIImagePickerController.SourceType){
        var imagePickerController: UIImagePickerController {
            get {
                let imagePicket = UIImagePickerController()
                imagePicket.delegate = self
                imagePicket.sourceType = type
                imagePicket.allowsEditing = true
                return imagePicket
            }
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //选完图片自动回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if picker.allowsEditing {
            image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "ShowOCRResult", sender: self.image)
        })
    }
    
    //视图传递数据
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowOCRResult"){
            let controller = segue.destination as! OCRView
            controller.image = sender as? UIImage
        }
    }
    
    @IBAction func Translate(_ sender: Any) {
        translate_post(url: "http://47.102.127.218:80/trans/translate", source: source.text, mode: language.selectedSegmentIndex)
    }
    
    func translate_post(url: String, source: String, mode: Int) {
        var postbody: String = "from=auto&to=auto&word="
        switch(mode)
        {
        case 0: postbody = "from=auto&to=ja&word=";break
        case 1: postbody = "from=ja&to=zh-CHS&word=";break
        default:break
        }
        postbody += source
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                let result = String(data: data!, encoding: .utf8)
                DispatchQueue.main.async {
                    self.destination.text = result?.removingPercentEncoding!
                }
            }
        }
        task.resume()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!source.isExclusiveTouch){
            source.resignFirstResponder()
        }
    }
    
    @IBOutlet var TranslateNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = {
            switch(UserDefaults.standard.string(forKey: "language")){
            case "zh-Hans-US": return "在线翻译"
            case "ja-US": return "オンライン翻訳"
            default: return "在线翻译"
            }
        }()
        
    }
}
