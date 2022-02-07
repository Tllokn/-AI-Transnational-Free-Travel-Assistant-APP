import base64
import io
import json
import os
import re
from urllib.request import urlopen

import numpy as np
import requests
import xlrd
from keras.applications.vgg16 import preprocess_input
from keras.preprocessing import image
from numpy import linalg
from PIL import Image as pil_image

if pil_image is not None:
    _PIL_INTERPOLATION_METHODS = {
        'nearest': pil_image.NEAREST,
        'bilinear': pil_image.BILINEAR,
        'bicubic': pil_image.BICUBIC,
    }
    # These methods were only introduced in version 3.4.0 (2016).
    if hasattr(pil_image, 'HAMMING'):
        _PIL_INTERPOLATION_METHODS['hamming'] = pil_image.HAMMING
    if hasattr(pil_image, 'BOX'):
        _PIL_INTERPOLATION_METHODS['box'] = pil_image.BOX
    # This method is new in version 1.1.3 (2013).
    if hasattr(pil_image, 'LANCZOS'):
        _PIL_INTERPOLATION_METHODS['lanczos'] = pil_image.LANCZOS

def load_img(imgData, grayscale=False, color_mode='rgb', target_size=None,
             interpolation='nearest'):
    if grayscale is True:
        warnings.warn('grayscale is deprecated. Please use '
                      'color_mode = "grayscale"')
        color_mode = 'grayscale'
    if pil_image is None:
        raise ImportError('Could not import PIL.Image. '
                          'The use of `array_to_img` requires PIL.')
    path = io.BytesIO(imgData)
    img = pil_image.open(path)
    if color_mode == 'grayscale':
        if img.mode != 'L':
            img = img.convert('L')
    elif color_mode == 'rgba':
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
    elif color_mode == 'rgb':
        if img.mode != 'RGB':
            img = img.convert('RGB')
    else:
        raise ValueError('color_mode must be "grayscale", "rbg", or "rgba"')
    if target_size is not None:
        width_height_tuple = (target_size[1], target_size[0])
        if img.size != width_height_tuple:
            if interpolation not in _PIL_INTERPOLATION_METHODS:
                raise ValueError(
                    'Invalid interpolation method {} specified. Supported '
                    'methods are {}'.format(
                        interpolation,
                        ", ".join(_PIL_INTERPOLATION_METHODS.keys())))
            resample = _PIL_INTERPOLATION_METHODS[interpolation]
            img = img.resize(width_height_tuple, resample)
    return img

def ImageSearchUrl(imageUrl):
    Url = 'https://graph.baidu.com/upload?'
    PostData = {
        "image": imageUrl,
        "tn": 'pc',
        "from": 'pc',
        "image_source": 'PC_UPLOAD_URL' 
    }
    r = requests.post(Url, data=PostData)
    doc = json.loads(r.text)
    if(doc['msg'] == 'Success'):
        print(doc['data']['url'])
    else:
        return None

def ImageSearchFile(imageData):
    # 需要加一个大图判断，如果分辨率太高，就压缩
    Url = 'https://graph.baidu.com/upload?'
    PostData = {
        "image": imageData,
        "tn": 'pc',
        "from": 'pc',
        "image_source": 'PC_UPLOAD_FILE' 
    }
    r = requests.post(Url, files=PostData)
    doc = json.loads(r.text)
    if(doc['msg'] == 'Success'):
        # print(doc)
        tempUrl = doc['data']['url']
        tempUrl += "&tpl_from=pc"
        print(tempUrl)
        pageSource = requests.get(url=tempUrl).text
        guessWord = re.findall('"subTitle":"(.*?)"', pageSource)
        # print(guessWord)
        if(len(guessWord) == 0):
            return None # 识别不成功
        else:
            return "{\"guessSpot\":\"" + guessWord[0] + "\"}" # 成功获取识别信息
    else:
        return None # Post不成功

def GenerateFeature(imgData, model, graph):
    img = load_img(imgData, target_size=(240, 160))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    with graph.as_default():
        feature = model.predict(x)
    norm_feature = feature[0] / linalg.norm(feature[0])
    norm_feature = norm_feature.reshape(-1)
    return norm_feature

def Query(imgData, model, graph, database_path='./ImageEncode', maxres=3):
    index = 0
    fea = GenerateFeature(imgData, model, graph)
    tot_sort_sim = []
    tot_sort_imgpath = []
    back_res = []
    while(True):
        fea_file = os.path.join(database_path, 'Data' + str(index) + '.bin')
        reader_file = os.path.join(database_path, 'Data' + str(index) + '.txt')
        reader_name = os.path.join(database_path, 'name.txt')
        if not (os.path.exists(fea_file)and os.path.exists(reader_file)and os.path.exists(reader_name)):
            break # 不存在了就退出
        
        fea_dict = np.fromfile(fea_file, dtype='float32')
        index_reader = open(reader_file, 'r')
        image_path = []
        while(True):
            lines = index_reader.readline()
            if not lines:break
            image_path.append(lines)
        index_reader.close()

        name_reader = open(reader_name, 'r', encoding='gbk')
        doc = dict()
        while(True):
            lines = name_reader.readline()
            if not lines:break
            l = list(lines.split())
            doc[int(l[0])] = l[1]
        name_reader.close()

        fea_dict = fea_dict.reshape(-1, len(fea))
        res = np.dot(fea, fea_dict.T)
        rank_ID = np.argsort(res)[::-1]
        for j, i in enumerate(rank_ID[0:maxres]):
            tot_sort_sim.append(res[i])
            tot_sort_imgpath.append(image_path[i])
        index += 1
    rank_ID = np.argsort(tot_sort_sim)[::-1]
    for i in range(maxres):
        prefix = re.findall('\./image\\\\(\d+)\\\\(\d+)\.jpg\\n', tot_sort_imgpath[rank_ID[i]])
        if(len(prefix) > 0):
            reader = open(os.path.join(database_path, 'src/' + prefix[0][0] + '.txt'))
            for j in range(int(prefix[0][1]) + 1):
                lines = reader.readline()
            reader.close()
        back_res.append({
            "label": doc[int(prefix[0][0])],
            "img_url": lines[:-1]
        })
    return json.dumps(back_res)



if __name__ == "__main__":
    print('This is image search api.')
    # data = open(r"C:\Users\hiijar\Desktop\test.jpg","rb")
    # name_reader = open('../ImageEncode/name.txt', 'r', encoding='gbk')
    # doc = dict()
    # while(True):
    #     lines = name_reader.readline()
    #     if not lines:break
    #     l = list(lines.split())
    #     doc[int(l[0])] = l[1]
    # name_reader.close()

    # plt.show()
    # print(img)
    # data = np.bytes(data)
    
    # print(data)
    # cv2.imshow('233', img)
    # cv2.waitKey(0)
    
    # print(data.shape)
    # print(ImageSearchFile(data))
    # print(ImageSearchMap(110.5, 30.5))
