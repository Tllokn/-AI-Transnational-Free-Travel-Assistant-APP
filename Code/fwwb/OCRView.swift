//
//  OCRView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/21.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class OCRView: UIViewController{
    
    var image:UIImage? = nil
    @IBOutlet var Image: UIImageView!
    @IBOutlet var ocrTable: OCRTable!
    
    
    @IBOutlet var loading: UIActivityIndicatorView!
    
    func OCRtranslatepost(url: String, image:UIImage){
        let imageData = image.jpegData(compressionQuality: 0.1)
        let base64 = imageData?.base64EncodedString()
        let base64string = base64!.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        let postbody: String = "image=data:image/png;base64," + base64string!
        
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    DispatchQueue.main.async {
                        self.ocrTable.Refresh(updatedData: json)
                        self.loading.stopAnimating()
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    
    
    @IBOutlet var OCRNavigationItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = {
            switch(UserDefaults.standard.string(forKey: "language")){
            case "zh-Hans-US": return "识图翻译"
            case "ja-US": return "写真で翻訳"
            default: return "识图翻译"
            }
        }()
        
        Image.image = image
        OCRtranslatepost(url: "http://47.102.127.218/trans/OCRtranslate", image: image!)
    }
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true
            , completion: nil)
    }
}

class OCRTable: UITableView, UITableViewDataSource{
    
    var data: NSArray? = nil
    
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.dataSource = self
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(data == nil){
            return 0
        }
        return data!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let source = cell?.viewWithTag(1) as! UILabel
        let translation = cell?.viewWithTag(2) as! UILabel
        
        let line = data![indexPath.row] as! NSDictionary
        source.text = line.object(forKey: "context") as? String
        translation.text = line.object(forKey: "tranContent1") as? String
        
        return cell!
    }
    
    func Refresh(updatedData: NSArray){
        data = updatedData
        reloadData()
    }
}
