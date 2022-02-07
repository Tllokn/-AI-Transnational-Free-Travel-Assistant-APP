from keras.applications.vgg16 import VGG16, preprocess_input
from keras.preprocessing import image
import tensorflow as tf 
model = VGG16(weights='vgg16_weights.h5', input_shape=(240, 160, 3),
              pooling='max', include_top=False)
# model.summary()
graph = tf.get_default_graph()

import base64
import re
from flask import Flask, render_template, request
from sys import path
path.append('./api')

import api.imageSearch as imgs
import api.translate as trans
import api.siteRecommend as strc
import api.register as reg
import api.login_and_logout as log
import api.feedback as fe

app = Flask(__name__)
port = 80

@app.route('/')
def home():
    HomePage = re.match(r'http://\d+\.\d+\.\d+\.\d+:\d+/', request.url)
    if(HomePage == None):
        HomePage = re.match(r'http://\d+\.\d+\.\d+\.\d+/', request.url)
        HomePage = HomePage.group()[:-1]
        HomePage += ':%d' % port
    else:
        HomePage = HomePage.group()[:-1]
    TranslationPage = HomePage + '/trans/translate'
    OCRPage = HomePage + '/trans/OCRtranslate'
    ImageSearchPage = HomePage + '/imageSearch'
    SiteRecommendPage = HomePage + '/siteRecommend'
    return render_template('HomePage.html', 
                            TranslationPage=TranslationPage, 
                            OCRPage=OCRPage, 
                            ImageSearchPage=ImageSearchPage,
                            SiteRecommendPage=SiteRecommendPage
    )

@app.route('/trans/translate', methods=['POST', 'GET'])
def translate():
    # http://127.0.0.1:5000/trans/translate?word=shit&from=Auto&To=Auto 需要改成这样也能访问的
    message = None
    From = None
    To = None
    if(request.method == 'POST'):    
        message = request.form['word']
        try:
            From = request.form['from']
        except:
            From = 'Auto'
        try:
            To = request.form['to']
        except:
            To = 'Auto' 
        message = str(trans.Translate(message, From, To))
    elif(request.method == 'GET'): 
        message = 'This is a translation api.'
        # return render_template('TranslationPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/trans/OCRtranslate', methods=['POST', 'GET'])
def OCRtranslate():
    message = None
    if(request.method == 'POST'):    
        message = request.form['image']
        message = str(trans.OCRTranslate(message, 'ja'))
    elif(request.method == 'GET'): 
        message = 'This is a OCRtranslation api.'
        # return render_template('OCRPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/trans/voiceTranslate', methods=['POST', 'GET'])
def voiceTranslate():
    message = None
    if(request.method == 'POST'):    
        message = request.form['voice']
        From = request.form['from']
        To = request.form['to']
        message = str(trans.VoiceTranslate(message, From, To))
        if(message == None):
            message = '{}'
    elif(request.method == 'GET'): 
        message = 'This is a VoiceTranslation api.'
    else:
        message = 'Error!'
    return message

@app.route('/imageSearch', methods=['POST', 'GET'])
def spotRecognition():
    if(request.method == 'POST'):    
        message = request.form['image']
        
        prefix = re.findall('(data:image/.*?;base64,)', message)
        if(len(prefix) > 0):message = message.replace(prefix[0], '')
        imgdata = base64.b64decode(message)
        # print(type(imgdata))
        # res = imgs.ImageSearchFile(imgdata)
        # if(res == None):
        #     res = imgs.ImageSearchMap(longitude, latitude, begin, count)
        res = imgs.Query(imgdata, model, graph)
        message = res
    elif(request.method == 'GET'): 
        message = 'This is a imageSearch api.'
        # return render_template('ImageSearchPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/siteRecommend', methods=['POST', 'GET'])
def spotRecommend():
    if(request.method == 'POST'):
        longitude = float(request.form['longitude'])
        latitude = float(request.form['latitude'])

        try: radius = float(request.form['distance'])
        except: radius = 1000 # 方圆一公里内

        try: standard = request.form['standard']
        except: standard = 'distance'

        try: begin = int(request.form['begin'])
        except: begin = 0
        
        try: count = int(request.form['count'])
        except: count = 5
        
        try: languange = request.form['language']
        except: languange = 'zh-CHS'

        message = strc.SiteRecommend(longitude, latitude, radius, begin, count, standard, languange)

    elif(request.method == 'GET'): 
        message = 'This is a siteRecommend api.'
        # return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/viewSite', methods=['POST', 'GET'])
def site():
    if(request.method == 'POST'):
        jdid = request.form['id']
        try: languange = request.form['language']
        except: languange = 'zh-CHS'
        message = strc.viewSite(jdid, languange)
    elif(request.method == 'GET'): 
        message = 'This is a viewSite api.'
        # return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/user/sendEmail', methods=['POST', 'GET'])
def sendEmail():
    if (request.method == 'POST'):
        try: languange = request.form['language']
        except: languange = 'zh-CHS'
        formed_data = {
            'email':request.form['email']
        }
        flag = reg.create_user(formed_data, languange)
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a sendEmail api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/user/validateEmail', methods=['POST', 'GET'])
def validation():
    if (request.method == 'POST'):
        formed_data = {
            'code': request.form['code'],
            'email': request.form['email'],
            'password': request.form['password']
        }
        flag = reg.validate(formed_data)
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a validateEmail api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message
# 登录
@app.route('/user/login', methods=['POST', 'GET'])
def login():
    if (request.method == 'POST'):
        email = request.form['email']
        password = request.form['password']
        message = log.login(email, password)
        # message = token if token else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a login api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message
# 登出
@app.route('/user/logout', methods=['POST', 'GET'])
def logout():
    if (request.method == 'POST'):
        email = request.form['email']
        token = request.form['token']
        flag = log.logout(email, token)
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a logout api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/user/feedback', methods=['POST', 'GET'])
def userStar():
    if (request.method == 'POST'):
        uid = request.form['user_id']
        jdid = request.form['jd_id']
        score = request.form['score']
        flag = fe.Grade(uid, jdid, float(score))
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a star api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/user/suggest', methods=['POST', 'GET'])
def userSuggest():
    if (request.method == 'POST'):
        uid = request.form['user_id']
        suggestion = request.form['suggestion']
        flag = fe.Opinion(uid, suggestion)
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a suggestion api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

@app.route('/user/collect', methods=['POST', 'GET'])
def userCollect():
    if (request.method == 'POST'):
        uid = request.form['user_id']
        jdid = request.form['jd_id']
        dis = request.form['cancel']
        if(dis == 'Y'):
            flag = fe.Discollect(uid, jdid)
        else:
            flag = fe.Collect(uid, jdid)
        message = 'Success!' if flag else 'Fail!'
    elif (request.method == 'GET'):
        message = 'This is a collection api.'
        #return render_template('SiteRecommendPage.html')
    else:
        message = 'Error!'
    return message

# @app.route('/user/getInfo', methods=['POST', 'GET'])
# def userGetInfo():
#     if (request.method == 'POST'):
#         uid = request.form['user_id']
#         message = fe.viewUser(uid)
#         # message = 'Success!' if flag else 'Fail!'
#     elif (request.method == 'GET'):
#         message = 'This is a getInfo api.'
#         #return render_template('SiteRecommendPage.html')
#     else:
#         message = 'Error!'
#     return message

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=port)
    # app.run()
