//
//  RecognizeDoneView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/21.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class RecognizeDoneView: UIViewController {

    var image: UIImage? = nil
    @IBOutlet var Image: UIImageView!
    @IBOutlet var Result: ResultTable!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    func recognize_post(url: String, image:UIImage){
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
                        self.Result.result = json
                        self.Result.reloadData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Image.image = image
        recognize_post(url: "http://47.102.127.218:80/imageSearch", image: image!)
        title = {
            switch(UserDefaults.standard.string(forKey: "language")){
            case "zh-Hans-US": return "识别结果"
            case "ja-US": return "結果"
            default: return "识别结果"
            }
        }()
    }
}

class ResultTable: UITableView, UITableViewDataSource{
    var result: NSArray!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(result == nil){
            return 0
        }
        else{
            return result.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dict = result![section] as! NSDictionary
        return dict.object(forKey: "label") as? String
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "cell")
        let label = cell?.viewWithTag(1) as! UILabel
        let image = cell?.viewWithTag(2) as! UIImageView
        let dict = result![indexPath.section] as! NSDictionary
        label.text = dict.object(forKey: "label") as? String
        let img_data = try? Data(contentsOf: URL(string: dict.object(forKey: "img_url") as! String)!)
        image.image = UIImage(data: img_data!)
        
        return cell!
    }
    
    
}
