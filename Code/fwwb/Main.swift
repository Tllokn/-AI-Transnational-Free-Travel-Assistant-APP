//
//  Main.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/26.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class Main: UITabBarController {
    
    @IBOutlet var MainTabBar: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let l = UserDefaults.standard.string(forKey: "language")
        
        MainTabBar.items![0].title = {
            switch(l){
            case "zh-Hans-US": return "推荐"
            case "ja-US": return "お勧め"
            default: return "推荐"
            }
        }()
        
        MainTabBar.items![1].title = {
            switch(l){
            case "zh-Hans-US": return "功能"
            case "ja-US": return "機能"
            default: return "功能"
            }
        }()
        
        MainTabBar.items![2].title = {
            switch(l){
            case "zh-Hans-US": return "我的"
            case "ja-US": return "本人"
            default: return "我的"
            }
        }()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectedViewController?.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedViewController?.endAppearanceTransition()
    }

}
