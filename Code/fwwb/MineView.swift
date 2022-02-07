//
//  MineView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/24.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class MineView: UITableViewController {

    @IBOutlet var Avater: UIImageView!
    @IBOutlet var Name: UILabel!
    @IBOutlet var Prompt: UILabel!
    
    let defaults = UserDefaults.standard
    var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.standard.string(forKey: "language") == "zh-Hans-US"){
            Language.selectedSegmentIndex = 0
        }
        else{
            Language.selectedSegmentIndex = 1
        }
        
    }
    
    
    
    @IBOutlet var MineNavigationItem: UINavigationItem!
    @IBOutlet var DistrictLabel: UILabel!
    @IBOutlet var LanguageLabel: UILabel!
    @IBOutlet var AboutLabel: UILabel!
    @IBOutlet var SuggestLabel: UILabel!
    @IBOutlet var EvaluateLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        
        switch(UserDefaults.standard.string(forKey: "language"))
        {
        case "ja-US":
            MineNavigationItem.title = "本人"
            Name.text = "未登録"
            Prompt.text = "他のサービス、ログインしてください"
            DistrictLabel.text = "地域選択"
            LanguageLabel.text = "言語選択"
            AboutLabel.text = "私たちについて"
            SuggestLabel.text = "意見のフィードバック"
            EvaluateLabel.text = "私に採点する"
        default:
            MineNavigationItem.title = "我的"
            Name.text = "未登录"
            Prompt.text = "点击登录以获取更多服务"
            DistrictLabel.text = "地区选择"
            LanguageLabel.text = "语言选择"
            AboutLabel.text = "关于我们"
            SuggestLabel.text = "意见反馈"
            EvaluateLabel.text = "给我评分"
        }
        
        isLogin = defaults.bool(forKey: "isLogin")
        if(isLogin){
            Avater.alpha = 1
            Name.textColor = .darkGray
            Name.text = defaults.string(forKey: "nickname")
            if(UserDefaults.standard.string(forKey: "language") == "zh-Hans-US"){
                Prompt.text = "自游助手将陪伴你的旅程"
            }
            else{
                Prompt.text = "自分の助手があなたの旅をする"
            }
        }
        else{
            Avater.alpha = 0.2
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section){
        case 0: return 1
        case 1: return 2
        case 2: return 3
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0){
            if(isLogin){
                performSegue(withIdentifier: "ShowMyDetail", sender: nil)
            }
            else{
                switch(UserDefaults.standard.string(forKey: "language")){
                case "zh-Hans-US": performSegue(withIdentifier: "ShowLogin", sender: nil)
                case "ja-US": performSegue(withIdentifier: "ShowLogin_JA", sender: nil)
                default:performSegue(withIdentifier: "ShowLogin", sender: nil)
                }
            }
        }
        
        if(indexPath.section == 2 && indexPath.row == 0){
            switch(Language.selectedSegmentIndex)
            {
            case 0: performSegue(withIdentifier: "ShowSuggest", sender: nil)
            case 1: performSegue(withIdentifier: "ShowSuggest_JA", sender: nil)
            default:performSegue(withIdentifier: "ShowSuggest", sender: nil)
            }
        }
        
        if(indexPath.section == 2 && indexPath.row == 1){
            
            switch(Language.selectedSegmentIndex)
            {
            case 0:
                let controller = UIAlertController(title : "是否前往App Store打分", message: "请为我们打上好评", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(title: "确定", style: .default){
                (action) in
                    let urlString = "itms-apps://itunes.apple.com/"
                    let url = URL(string: urlString)
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                })
                present(controller, animated: true)
                
            case 1:
                let controller = UIAlertController(title : "App Storeで得点する", message: "私たちに好評をお願いします", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(title: "確定", style: .default){
                (action) in
                    let urlString = "itms-apps://itunes.apple.com/"
                    let url = URL(string: urlString)
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                })
                present(controller, animated: true)
                
            default:
                let controller = UIAlertController(title : "是否前往App Store打分", message: "请为我们打上好评", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(title: "确定", style: .default){
                (action) in
                    let urlString = "itms-apps://itunes.apple.com/"
                    let url = URL(string: urlString)
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                })
                present(controller, animated: true)
            }
        }
    }
    
    @IBOutlet var Language: UISegmentedControl!
    @IBAction func ChanageLanguage(_ sender: Any) {
        
        switch(Language.selectedSegmentIndex)
        {
        case 0:
            UserDefaults.standard.set("zh-Hans-US", forKey: "language")

        case 1:
            UserDefaults.standard.set("ja-US", forKey: "language")

        default:
            UserDefaults.standard.set("zh-Hans-US", forKey: "language")
        }
        
        let alert = UIAlertController(title: "切换成功\n成功を切り替える", message: "请重启App生效\n再起動アプリケーションの発効", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
