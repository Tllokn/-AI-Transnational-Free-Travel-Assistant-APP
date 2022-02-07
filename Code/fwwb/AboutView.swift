//
//  AboutView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/5.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class AboutView: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var aboutTable: UITableView!
    let l = UserDefaults.standard.string(forKey: "language")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let label = cell?.viewWithTag(1) as! UILabel
        switch(indexPath.row){
        case 0: label.text = {
            switch(l){
            case "zh-Hans-US": return "更新检查"
            case "ja-US": return "検査を更新する"
            default: return "更新检查"
            }
        }()
        case 1: label.text = {
            switch(l){
            case "zh-Hans-US": return "使用帮助"
            case "ja-US": return "助けを使う"
            default: return "使用帮助"
            }
        }()
        default : label.text = ""
        }
        
        return cell!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutTable.delegate = self
        aboutTable.dataSource = self
    }
}
