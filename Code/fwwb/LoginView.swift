//
//  LoginView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/25.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class LoginView: UIViewController{
    
    @IBOutlet var Email: UITextField!
    @IBOutlet var Password: UITextField!
    
    @IBAction func Login(_ sender: Any) {
        login_post(url: "http://47.102.127.218:80/user/login", email: Email.text!, password: Password.text!)
    }
    
    func login_post(url: String, email: String, password: String){
        var postbody = "email=" + email
        postbody += "&password=" + password
        
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    print(json)
                    DispatchQueue.main.async {
                        if(json == [:]){
                            let alert = UIAlertController(title: "登录失败", message: "请检查账号或密码是否正确", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        else{
                            let defaults = UserDefaults.standard
                            defaults.set(true, forKey: "isLogin")
                            defaults.set(json.object(forKey: "token") as! String, forKey: "token")
                            defaults.set(json.object(forKey: "user_id") as! String, forKey: "user_id")
                            defaults.set(json.object(forKey: "nickname"), forKey: "nickname")
                            defaults.set(json.object(forKey: "role") as! String, forKey: "role")
                            defaults.set(json.object(forKey: "collections") as! NSArray, forKey: "collection")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(Email.isExclusiveTouch){
            Email.resignFirstResponder()
        }
        if(Password.isExclusiveTouch){
            Password.resignFirstResponder()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
