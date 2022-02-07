import json

from geopy.distance import geodesic

from DataBase import Database


def SiteRecommend(longitude, latitude, radius=1000, begin=0, count=5, sort_standard='distance', language=''):
    if(language == 'ja'): language = '_ja'
    else: language = ''
    DB = Database(db='appdata')
    if(sort_standard == 'score'):
        sql = 'SELECT *,(12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))) current_dis\
            FROM sightseeing%s WHERE 12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))< %f\
            ORDER BY score DESC, current_dis ASC LIMIT %d,%d;'%(latitude, latitude, longitude, language, latitude, latitude, longitude, radius, begin, count)
    elif(sort_standard == 'hot_level'):
        sql = 'SELECT *,(12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))) current_dis\
            FROM sightseeing%s WHERE 12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))< %f\
            ORDER BY hot_level DESC, current_dis ASC LIMIT %d,%d;'%(latitude, latitude, longitude, language, latitude, latitude, longitude, radius, begin, count)
    elif(sort_standard == 'distance'):
        sql = 'SELECT *,(12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))) current_dis\
            FROM sightseeing%s WHERE 12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))< %f\
            ORDER BY current_dis ASC LIMIT %d,%d;'%(latitude, latitude, longitude, language, latitude, latitude, longitude, radius, begin, count)
    else: 
        sql = 'SELECT *,(12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))) current_dis\
            FROM sightseeing%s WHERE 12742000*ASIN(SQRT(POW(SIN((%f-latitude)*PI()/360),2)+COS(latitude*PI()/180)*COS(%f*PI()/180)*POW(SIN((%f-longitude)*PI()/360),2)))< %f\
            ORDER BY level DESC, LN(current_dis)*(6*hot_level+0.8*score) ASC LIMIT %d,%d;'%(latitude, latitude, longitude, language, latitude, latitude, longitude, radius, begin, count)
    selectedData = DB.select(sql) 
    
    jsonData = ""
    for (jd_id, jd_name, jd_address, jd_hot_level, jd_price, jd_level, jd_sale_count, 
        jd_img_url, jd_describe, jd_longtitude, jd_latitude, jd_score, jd_cur_dist) in selectedData:
        jsonFormed = {
            "id": jd_id,
            "name": jd_name, 
            "price": jd_price,
            "address": jd_address,
            "hot_level": jd_hot_level,
            # "level": jd_level,
            # "longitude": jd_longtitude,
            # "latitude": jd_latitude,
            "img_url": jd_img_url,
            "sale_count": jd_sale_count, 
            # "open_time": jd_open_time,
            # "url": jd_url,
            # "describe": jd_describe,
            # "transfer_desc": jd_transfer_desc,
            "score": jd_score,
            "distance": jd_cur_dist
        }
        jsonFormed = json.dumps(jsonFormed)
        jsonData += jsonFormed + ", "
    if(jsonData == ""):jsonData = "[]"
    else:jsonData = "[" + jsonData[:-2] + "]"
    return jsonData

def viewSite(jdid, language=''):
    if(language == 'ja'): language = '_ja'
    else: language = ''
    DB = Database(db='appdata')
    sql = 'SELECT * FROM sightseeing%s WHERE id = "%s"' % (language, jdid)
    selectedData = DB.select(sql)
    for (jd_id, jd_name, jd_address, jd_hot_level, jd_price, jd_level, jd_sale_count, 
        jd_img_url, jd_describe, jd_longtitude, jd_latitude, jd_score) in selectedData:
        jsonFormed = {
            "id": jd_id,
            "name": jd_name, 
            "price": jd_price,
            "address": jd_address,
            "hot_level": jd_hot_level,
            "level": jd_level,
            "longitude": jd_longtitude,
            "latitude": jd_latitude,
            "img_url": jd_img_url,
            "sale_count": jd_sale_count, 
            "describe": jd_describe,
            "score": jd_score
        }
        jsonFormed = json.dumps(jsonFormed)
        return jsonFormed
    return None
     
if __name__ == "__main__":
    print('This is site recommend api.')
    # print(SiteRecommend(118, 31, 3000, 0, 5, 'complex'))
