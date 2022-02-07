//
//  MyDetailView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/1.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class MyDetailView: UITableViewController {

    @IBOutlet var Name: UITextField!
    @IBOutlet var Email: UILabel!
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var RenameButton: UIButton!
    @IBAction func BeginRename(_ sender: Any) {
        RenameButton.isHidden = false
    }
    @IBAction func Rename(_ sender: Any) {
        defaults.set(Name.text, forKey: "nickname")
        RenameButton.isHidden = true
        Name.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Name.text = defaults.string(forKey: "nickname")
    }
    
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
        case 0: return 1
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 1 && indexPath.row == 1){
            performSegue(withIdentifier: "ShowCollection", sender: nil)
        }
        
        if(indexPath.section == 2 && indexPath.row == 0){
            
            let alert = UIAlertController(title: "是否确定退出？", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { (a: UIAlertAction) in
                self.defaults.set(false, forKey: "isLogin")
                self.defaults.set("", forKey: "Token")
                self.defaults.set("", forKey: "Name")
                self.navigationController?.popViewController(animated: true)
                }
            ))
            
            present(alert, animated: true)
        }
    }

}
