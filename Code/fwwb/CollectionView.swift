//
//  CollectionView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/6.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class CollectionView: UITableViewController {
    
    let collection = UserDefaults.standard.mutableArrayValue(forKey: "collection")
    
    @IBOutlet var _refresh: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        _refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl = _refresh
    }
    
    @objc func refreshData(){
        _refresh.endRefreshing()
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let ID = cell?.viewWithTag(4) as! UILabel
        let Name = cell?.viewWithTag(1) as! UILabel
        let Image = cell?.viewWithTag(2) as! UIImageView
        let Location = cell?.viewWithTag(3) as! UILabel
        
        let postbody = "id=" + (collection.object(at: indexPath.row) as! String)
        let session = URLSession.shared
        var request = URLRequest(url: URL(string : "http://47.102.127.218:80/viewSite")!)
        
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    DispatchQueue.main.async {
                        ID.text = json.object(forKey: "id") as? String
                        Name.text = json.object(forKey: "name") as? String
                        Location.text = json.object(forKey: "address") as? String
                        Image.image = UIImage(data: try! Data(contentsOf: URL(string: json.object(forKey: "img_url") as! String)!))
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        task.resume()
        
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CollectionShowDetail"){
            let controller = segue.destination as! RecommendDetailView
            let cell = sender as! UITableViewCell
            let id = cell.viewWithTag(4) as! UILabel
            controller.id = id.text
        }
    }

}
