//
//  RecommendView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/23.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit
import CoreLocation

class RecommendView: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mode: UISegmentedControl!
    @IBAction func modeChange(_ sender: Any) {
        loading.startAnimating()
        refreshData()
    }
    
    var curLocation: CLLocation!
    let locationManager: CLLocationManager = {
        var lM = CLLocationManager()
        lM.desiredAccuracy = kCLLocationAccuracyBest
        lM.distanceFilter = kCLLocationAccuracyBest
        return lM
    }()
    
    @IBOutlet var Location: UILabel!
    
    var data: NSMutableArray! = NSMutableArray()
    var page: Int32 = 0
    
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var RecommendNavigationItem: UINavigationItem!
    
    
    @IBOutlet var _refresh: UIRefreshControl!
    
    @objc func refreshData(){
        page = 0
        data = NSMutableArray()
        locationManager.startUpdatingLocation()
        _refresh.endRefreshing()
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch(UserDefaults.standard.string(forKey: "language")){
        case "zh-Hans-US":
            mode.setTitle("综合排序", forSegmentAt: 0)
            mode.setTitle("距离优先", forSegmentAt: 1)
            mode.setTitle("热度优先", forSegmentAt: 2)
        case "ja-US":
            mode.setTitle("総合順位", forSegmentAt: 0)
            mode.setTitle("優先距離", forSegmentAt: 1)
            mode.setTitle("優先熱度", forSegmentAt: 2)
        default:
            mode.setTitle("综合排序", forSegmentAt: 0)
            mode.setTitle("距离优先", forSegmentAt: 1)
            mode.setTitle("热度优先", forSegmentAt: 2)
        }
        _refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl = _refresh
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        curLocation = locations.last!
        
        if(curLocation.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            CLGeocoder().reverseGeocodeLocation(curLocation){
                (placemarks, error) -> Void in
                if(error == nil){
                    let placemark = (placemarks! as NSArray).firstObject as! CLPlacemark
                    switch(UserDefaults.standard.string(forKey: "language")){
                    case "zh-Hans-US":
                        self.Location.text = "当前位置：  " + placemark.name!
                    case "ja-US":
                        self.Location.text = "現在地：  " + placemark.name!
                    default:
                        self.Location.text = "当前位置：  " + placemark.name!
                    }
                }
                else{
                    print(error!)
                }
            }
            
            recommend_post(url: "http://47.102.127.218:80/siteRecommend", location: curLocation, i: 0, mode: Int32(mode!.selectedSegmentIndex))
        }
    }
    
    func recommend_post(url: String, location: CLLocation, i: Int32, mode: Int32) {
        let modeString: String = {
            switch(mode){
            case 0: return "complex"
            case 1: return "distance"
            case 2: return "hot_level"
            default: return "score"
            }
        }()
        
        var postbody: String = ""
        postbody += "longitude=" + String(location.coordinate.longitude)
        postbody += "&latitude=" + String(location.coordinate.latitude)
        postbody += "&distance=5000"
        postbody += "&standard=" + modeString
        if(UserDefaults.standard.string(forKey: "language") == "ja-US"){
            postbody += "&language=ja"
        }
        postbody += "&begin=" + {
            if(i == 0){
                return "0"
            }
            else{
                return String(i * 20)
            }
        }()
        postbody += "&count=20"
        
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
                        self.data.addObjects(from: json as! [Any])
                        self.page += 1
                        self.tableView.reloadData()
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(data == nil){
            return 0
        }
        return data!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        
        let name = cell?.viewWithTag(1) as! UILabel
        let image = cell?.viewWithTag(2) as! UIImageView
        let location = cell?.viewWithTag(3) as! UILabel
        let distance = cell?.viewWithTag(5) as! UILabel
        let hot_level = cell?.viewWithTag(6) as! UILabel
        let id = cell?.viewWithTag(7) as! UILabel
        
        let dict = data![indexPath.row] as! NSDictionary
        id.text = dict.object(forKey: "id") as? String
        name.text = dict.object(forKey: "name") as? String
        location.text = dict.object(forKey: "address") as? String
        distance.text = {
            let d = (dict.object(forKey: "distance") as! NSNumber).int32Value
            if(d > 1000){
                let d_km = Double(d)/1000
                return  String(format: "%.2fkm", d_km)
            }
            return "\(d)m"
        }()
        hot_level.text = {
            let h = (dict.object(forKey: "hot_level") as! NSNumber).doubleValue * 5
            if(h == 0){
                return ""
            }
            return String(format: "%.1f分/5.0分", h)
            }()
        
        let img_data = try? Data(contentsOf: URL(string: dict.object(forKey: "img_url") as! String)!)
        image.image = UIImage(data: img_data!)
        
        return cell!
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom) <= 0 && scrollView.contentOffset.y > 0){
            let height = scrollView.frame.size.height;
            let contentOffsetY = scrollView.contentOffset.y;
            let bottomOffset = scrollView.contentSize.height - contentOffsetY;
            if(bottomOffset <= height){
                loading.startAnimating()
                recommend_post(url: "http://47.102.127.218:80/siteRecommend", location: curLocation, i:page, mode: Int32(mode!.selectedSegmentIndex))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowDetail"){
            let viewController = segue.destination as! RecommendDetailView
            let cell = sender as! UITableViewCell
            viewController.curLocation = curLocation
            viewController.id = (cell.viewWithTag(7) as! UILabel).text
        }
    }
    
    

}
