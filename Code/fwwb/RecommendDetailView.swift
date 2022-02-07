//
//  RecommendDetailView1.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/3.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RecommendDetailView: UITableViewController {
    
    let defaults = UserDefaults.standard
    var curLocation: CLLocation!
    var id:String!
    var destLocation: CLLocation!
    
    @IBOutlet var Image: UIImageView!
    @IBOutlet var Name: UILabel!
    @IBOutlet var Address: UILabel!
    @IBOutlet var Hot_Level: UILabel!
    @IBOutlet var Description: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recommenddetail_post(url: "http://47.102.127.218:80/viewSite", id: id)
        let collection = defaults.mutableArrayValue(forKey: "collection")
        if(collection.contains(id!)){
            CollectButton.isHidden = true
            UnCollectButton.isHidden = false
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }

    func recommenddetail_post(url: String, id: String){
        var postbody = "id=" + id
        if(UserDefaults.standard.string(forKey: "language") == "ja-US"){
            postbody += "&language=ja"
        }
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    DispatchQueue.main.async {
                        self.LoadDetail(json: json)
                        self.tableView.reloadData()
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func LoadDetail(json: NSDictionary){
        destLocation = CLLocation(latitude: json.object(forKey: "latitude") as! CLLocationDegrees, longitude: json.object(forKey: "longitude") as! CLLocationDegrees)
        let img_data = try? Data(contentsOf: URL(string: json.object(forKey: "img_url") as! String)!)
        Image.image = UIImage(data: img_data!)
        Name.text = json.object(forKey: "name") as? String
        Address.text = json.object(forKey: "address") as? String
        Hot_Level.text = {
            let h = (json.object(forKey: "hot_level") as! NSNumber).doubleValue * 5
            return String(format: "%.1f分/5.0分", h)
        }()
        Description.text = json.object(forKey: "describe") as? String
    }

    var navigateController: UIAlertController{
        let controller = UIAlertController(title : nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "为我导航", style: .default){
            (action) in
            let beginItem = MKMapItem(placemark: MKPlacemark(coordinate: self.curLocation.coordinate))
            let endItem = MKMapItem(placemark: MKPlacemark(coordinate: self.destLocation.coordinate))
            MKMapItem.openMaps(with: [beginItem, endItem], launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        })
        
        if let popoverController = controller.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: 0,y: 0,width: 1.0,height: 1.0)
        }
        return controller
    }
    
    @IBAction func Navigate(_ sender: Any) {
        present(navigateController, animated: true)
    }
    
    @IBOutlet var UnCollectButton: UIButton!
    @IBOutlet var CollectButton: UIButton!
    
    @IBAction func Collect(_ sender: Any) {
        collect_post(url: "http://47.102.127.218:80/user/collect", id: id, cancel: false)
        
        let collection = defaults.mutableArrayValue(forKey: "collection")
        let copy = collection.mutableCopy() as! NSMutableArray
        copy.add(id!)
        defaults.set(copy, forKey: "collection")
        CollectButton.isHidden = true
        UnCollectButton.isHidden = false
    }
    
    @IBAction func UnCollect(_ sender: Any) {
        collect_post(url: "http://47.102.127.218:80/user/collect", id: id, cancel: true)
        
        let collection = defaults.mutableArrayValue(forKey: "collection")
        let copy = collection.mutableCopy() as! NSMutableArray
        copy.remove(id!)
        defaults.set(copy, forKey: "collection")
        CollectButton.isHidden = false
        UnCollectButton.isHidden = true
    }
    
    func collect_post(url: String, id: String, cancel: Bool){
        if let user_id = UserDefaults.standard.string(forKey: "user_id"){
            let session = URLSession.shared
            var request = URLRequest(url: URL(string: url)!)
            
            var postbody = "user_id=" + user_id
            postbody += "&jd_id=" + id
            if(cancel){
                postbody += "&cancel=Y"
            }
            else{
                postbody += "&cancel=N"
            }
            
            request.httpMethod = "POST"
            request.httpBody = postbody.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request){
                (data, res, error) in
                if(error == nil){
                    DispatchQueue.main.async {
                        if(!cancel){
                            let alert = UIAlertController(title: "收藏成功", message: "可前往我的收藏查看", preferredStyle: .alert)
                            self.present(alert, animated: true)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.vanish), userInfo: alert, repeats: false)
//                            self.perform(#selector(self.dismiss), with: alert, afterDelay: 0.5)
                        }
                        else{
                            let alert = UIAlertController(title: "取消收藏成功", message: "将不会在您的收藏夹显示", preferredStyle: .alert)
                            self.present(alert, animated: true)
                            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.vanish), userInfo: alert, repeats: false)
                        }
                    }
                }
            }
            task.resume()
        }
        else{
            let alert = UIAlertController(title: "请先登录", message: "登录后即可收藏", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @objc func vanish(timer: Timer){
        let alert = timer.userInfo as! UIAlertController
        alert.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var Star1: UIButton!
    @IBOutlet var Star2: UIButton!
    @IBOutlet var Star3: UIButton!
    @IBOutlet var Star4: UIButton!
    @IBOutlet var Star5: UIButton!
    
    let star_url = Bundle.main.path(forResource: "star", ofType: "png")
    let stared_url = Bundle.main.path(forResource: "stared", ofType: "png")
    
    @IBAction func OneStar(_ sender: Any) {
        Star1.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star2.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star3.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star4.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star5.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        score_post(url: "http://47.102.127.218:80/user/feedback", id: id, score: 1)
    }
    
    @IBAction func TwoStar(_ sender: Any) {
        Star1.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star2.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star3.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star4.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star5.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        score_post(url: "http://47.102.127.218:80/user/feedback", id: id, score: 2)
    }
    
    @IBAction func ThreeStar(_ sender: Any) {
        Star1.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star2.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star3.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star4.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        Star5.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        score_post(url: "http://47.102.127.218:80/user/feedback", id: id, score: 3)
    }
    
    @IBAction func FourStar(_ sender: Any) {
        Star1.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star2.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star3.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star4.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star5.setImage(UIImage(contentsOfFile: star_url!), for: .normal)
        score_post(url: "http://47.102.127.218:80/user/feedback", id: id, score: 4)
    }
    
    @IBAction func FiveStar(_ sender: Any) {
        Star1.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star2.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star3.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star4.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        Star5.setImage(UIImage(contentsOfFile: stared_url!), for: .normal)
        score_post(url: "http://47.102.127.218:80/user/feedback", id: id, score: 5)
    }
    
    func score_post(url: String, id: String, score: Int){
        if let user_id = UserDefaults.standard.string(forKey: "user_id"){
            var postbody = "user_id=" + user_id
            postbody += "&jd_id=" + id
            postbody += "&score=" + String(score)
            
            let session = URLSession.shared
            var request = URLRequest(url: URL(string: url)!)
            
            request.httpMethod = "POST"
            request.httpBody = postbody.data(using: String.Encoding.utf8)
            
            let task = session.dataTask(with: request){
                (data, res, error) in
                if(error == nil){
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "评分成功", message: "感谢你的评价", preferredStyle: .alert)
                        self.present(alert, animated: true)
                        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.vanish), userInfo: alert, repeats: false)
                    }
                }
            }
            task.resume()
        }
        else{
            let alert = UIAlertController(title: "请先登录", message: "登录后即可参与评分", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}
