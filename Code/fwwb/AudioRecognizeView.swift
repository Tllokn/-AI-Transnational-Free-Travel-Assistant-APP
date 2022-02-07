//
//  AudioRecognize.swift
//  fwwb
//
//  Created by 施渝斌 on 2019/3/5.
//  Copyright © 2019 FxSn. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecognizeView: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var recordTable: UITableView!
    var data: NSMutableArray! = NSMutableArray()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let Source = cell?.viewWithTag(1) as! UILabel
        let Translate = cell?.viewWithTag(2) as! UILabel
        
        let dict = data!.object(at: indexPath.row) as! NSDictionary
        Source.text = dict.object(forKey: "content") as? String
        Translate.text = dict.object(forKey: "tranContent") as? String
        return cell!
    }
    
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    let settings = [AVSampleRateKey: NSNumber(value: 16000),//采样率
        AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),//音频格式
        AVLinearPCMBitDepthKey: NSNumber(value: 16),//采样位数
        AVNumberOfChannelsKey: NSNumber(value: 1),//通道数
        AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.min.rawValue)//录音质量
    ]
    let file_path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/record.wav")
    
    @IBAction func ChineseTouchDown(_ sender: Any) {
        let url = URL(fileURLWithPath: file_path!)
        recorder = try! AVAudioRecorder(url: url, settings: settings)
        recorder?.prepareToRecord()
        recorder?.record()
    }
    
    @IBAction func ChineseTouchUp(_ sender: Any) {
        if(recorder!.isRecording){
            recorder?.stop()
            print("done")
            recognize_post(url: "http://47.102.127.218:80/trans/voiceTranslate", mode: 0)
        }
    }
    
    @IBAction func JapaneseTouchDown(_ sender: Any) {
        let url = URL(fileURLWithPath: file_path!)
        recorder = try! AVAudioRecorder(url: url, settings: settings)
        recorder?.prepareToRecord()
        recorder?.record()
    }
    
    @IBAction func JapaneseTouchUp(_ sender: Any) {
        if(recorder!.isRecording){
            recorder?.stop()
            print("done")
            recognize_post(url: "http://47.102.127.218:80/trans/voiceTranslate", mode: 1)
        }
    }
    
    
    
    @IBAction func PlayButton(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let row = recordTable.indexPath(for: cell)?.row
        let dict = data.object(at: row!) as! NSDictionary
        let url = URL(string: dict.object(forKey: "reader_url") as! String)
        let audioData = try! Data(contentsOf: url!)
        player = try! AVAudioPlayer(data: audioData)
        player?.play()
    }
    
    @IBAction func RecordPlay(_ sender: Any) {
        do{
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file_path!))
            player?.play()
        }
        catch{
            print("\(error)")
        }
    }
    
    func recognize_post(url: String, mode: Int){
        let recordData = try! Data(contentsOf: URL(fileURLWithPath: file_path!))
        let base64 = recordData.base64EncodedString()
        let base64string = base64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        
        var postbody: String = "voice=" + base64string!
        
        if(mode == 0){
            postbody += "&from=zh-CHS"
            postbody += "&to=ja"
        }
        else{
            postbody += "&from=ja"
            postbody += "&to=zh-CHS"
        }
        
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
                        self.recordTable.reloadData()
                    }
                }
                catch{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "未能识别", message: "请重试一次", preferredStyle: .alert)
                        self.present(alert, animated: true)
                        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.vanish), userInfo: alert, repeats: false)
                    }
                }
            }
        }
        task.resume()
    }
    
    @objc func vanish(timer: Timer){
        let alert = timer.userInfo as! UIAlertController
        alert.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordTable.dataSource = self
        recordTable.delegate = self
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try! session.setActive(true, options: .notifyOthersOnDeactivation)
    }
}
