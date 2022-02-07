import requests
import json

import base64
import hashlib
import random

def Translate(Word, From="Auto", To="Auto"):
    Url = 'https://aidemo.youdao.com/trans'
    PostData = {
        "q": Word,
        "from": From,
        "to": To
    }
    r = requests.post(Url, data=PostData)
    doc = json.loads(r.text)
    return doc['translation'][0]

def OCRTranslate(Data, To='Auto'):
    Url = 'https://aidemo.youdao.com/ocrtransapi1'

    PostData = {
        "imgBase": Data,
        "company": ''
    }
    r = requests.post(Url, data=PostData)
    doc = json.loads(r.text)
    if(doc['errorCode'] == '0'):
        # doc = json.dumps(doc)
        doc = doc['lines']
        if(To != 'Auto'):
            for i in range(len(doc)):
                # doc[i]['tranContent']
                doc[i]['tranContent1'] = Translate(doc[i]['context'], 'Auto', To)
        return json.dumps(doc)
    else:return None

def VoiceTranslate(q, From, To):
    Url = 'https://openapi.youdao.com/asrapi'
    son_url = 'https://aidemo.youdao.com/ttsapi'
    app_key = "029b45a650b9b6aa"
    app_secret = "r6amf62QY8j7OTiQ8Bfn4G3NtPgrMEND"

    data = {}
    salt = random.randint(1, 65536)

    sign = app_key + q + str(salt) + app_secret
    m1 = hashlib.md5()
    m1.update(sign.encode('utf-8'))
    sign = m1.hexdigest()

    data['appKey'] = app_key
    data['q'] = q
    data['salt'] = salt
    data['sign'] = sign
    data['langType'] = From
    data['channel'] = 1
    data['rate'] = 16000
    data['format'] = 'wav'
    data['type'] = 1
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    doc = requests.post(Url, data=data, headers=headers).text
    doc = json.loads(doc)
    res = []
    print(doc)
    if(doc['errorCode'] == '0'):
        doc = doc['result']
        for i in range(len(doc)):
            fanyi = Translate(doc[i], From, To)
            data = {
                'text': fanyi,
                'speed': 1,
                'lan': 'auto'
            }
            son_doc = requests.post(son_url, data=data).text
            son_doc = json.loads(son_doc)
            if(son_doc['errorCode'] == '0'):
                reader_url = son_doc['data']
            else:
                reader_url = ""
            res.append({
                'content': doc[i],
                'tranContent': fanyi,
                'reader_url': reader_url
            })
        return json.dumps(res)
    else:return None

if __name__ == "__main__":
    print('This is translate api.')
    # print(Translate("hello"))
    data = open(r'C:\Users\hiijar\Desktop\wav.wav','rb').read() # 读入图片的二进制数据
    # Base64Image = base64.b64encode(data).decode() # 用Base64进行编码
    # Image = 'data:image/png;base64,' + Base64Image # 加上固定前缀
    # print(OCRTranslate(Image, 'ja'))
    url = 'http://scs.openspeech.cn/scs'
    # print(VoiceTranslate(Base64Image, "ja", "ko"))
    r = requests.post(url, files={'file':data})
    print(r.content)