//
//  RegisterView.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/2/24.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit

class RegisterView: UIViewController{
    
    let ja = (UserDefaults.standard.string(forKey: "language") == "ja-US")
    
    @IBOutlet var Email: UITextField!
    @IBOutlet var Code: UITextField!
    
    @IBOutlet var Password: UITextField!
    @IBOutlet var RepeatPassword: UITextField!
    
    @IBOutlet var GetCodeButton: UIButton!
    @IBAction func GetCode(_ sender: UIButton) {
        let email = Email.text
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if(predicate.evaluate(with: email)){
            getcode_post(url:"http://47.102.127.218:80/user/sendEmail", email: email!)
            GetCodeButton.isEnabled = false
        }
        else{
            let alert = UIAlertController(title: "邮箱地址有误", message: "请输入正确的邮箱地址", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func getcode_post(url:String, email:String){
        var postbody = "email=" + email
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
                let result = String(data: data!, encoding: .utf8)
                DispatchQueue.main.async {
                    if(result == "Success!"){
                        if(self.ja){
                            let alert = UIAlertController(title: "成功を得る", message: "メールでチェックしてください", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "確定する", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        else{
                            let alert = UIAlertController(title: "获取成功", message: "请前往您的邮箱查看", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        if(self.ja){
                            let alert = UIAlertController(title: "メールは既に登録されています", message: "直接ログインしてください", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "確定する", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        else{
                            let alert = UIAlertController(title: "该邮箱已经被注册", message: "请直接返回登录", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func Register(_ sender: Any) {
        let email = Email.text
        let code = Code.text
        let password = Password.text
        let repeatpassword = RepeatPassword.text
        
        if(password!.count < 6){
            if(ja){
                let alert = UIAlertController(title: "パスワードが弱い", message: "6ビットより高いパスワードを入力してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定する", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            else{
                let alert = UIAlertController(title: "密码太弱", message: "请输入高于六位的密码", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        if(password != repeatpassword){
            if(ja){
                let alert = UIAlertController(title: "2回の入力パスワードが一致しません", message: "パスワードを再入力してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "確定する", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            else{
                let alert = UIAlertController(title: "两次输入密码不一致", message: "请重新输入密码", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
        }
        
        register_post(url: "http://47.102.127.218:80/user/validateEmail", email: email!, code: code!, password: password!)
    }
    
    func register_post(url:String, email:String, code: String, password: String){
        var postbody = "email=" + email
        postbody += "&code=" + code
        postbody += "&password=" + password
        
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.httpBody = postbody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request){
            (data, res, error) in
            if(error == nil){
                let result = String(data: data!, encoding: .utf8)
                
                DispatchQueue.main.async {
                    if(result == "Success!"){
                        let alert = UIAlertController(title: "注册成功", message: "请返回登录", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else{
                        let alert = UIAlertController(title: "注册失败", message: "请检查你填写的的信息", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        task.resume()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(Email.isExclusiveTouch){
            Email.resignFirstResponder()
        }
        if(Code.isExclusiveTouch){
            Code.resignFirstResponder()
        }
        if(Password.isExclusiveTouch){
            Password.resignFirstResponder()
        }
        if(RepeatPassword.isExclusiveTouch){
            RepeatPassword.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
