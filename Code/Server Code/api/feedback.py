import json
from DataBase import Database

def Grade(uid, jdid, score=5.):
    DB = Database('appdata')
    try:
        select_sql = 'select user_id from jd_grade where user_id = "%s" and jd_id = "%s"' % (uid, jdid)
        if(DB.select(select_sql)):
            sql = 'update jd_grade set score = %f where user_id = "%s" and jd_id = "%s"' % (score, uid, jdid)
            DB.update(sql)
        else:
            sql = 'insert into jd_grade (user_id, jd_id, score) values ("%s", "%s", %f)' % (uid, jdid, score)
            DB.insert(sql)
    except Exception as e:
        print('[Error]:', e)
        return False
    return True

def Opinion(uid, suggestion):
    DB = Database('appdata')
    try:
        sql = 'insert into feedback (user_id, suggestion) values ("%s", "%s")' % (uid, suggestion)
        DB.insert(sql)
    except Exception as e:
        print('[Error]:', e)
        return False
    return True

def Collect(uid, jdid):
    DB = Database('appdata')
    try:
        select_sql = 'select user_id from jd_collect where user_id = "%s" and jd_id = "%s"' % (uid, jdid)
        if(DB.select(select_sql)):
            pass
        else:
            sql = 'insert into jd_collect (user_id, jd_id) values ("%s", "%s")' % (uid, jdid)
            DB.insert(sql)
    except Exception as e:
        print('[Error]:', e)
        return False
    return True

def Discollect(uid, jdid):
    DB = Database('appdata')
    try:
        select_sql = 'select user_id from jd_collect where user_id = "%s" and jd_id = "%s"' % (uid, jdid)
        if(DB.select(select_sql)):
            sql = 'delete from jd_collect where user_id = "%s" and jd_id = "%s"' % (uid, jdid)
            DB.delete(sql)
        else:pass
    except Exception as e:
        print('[Error]:', e)
        return False
    return True

def viewUser(uid):
    DB = Database('appdata')
    try:
        select_sql = 'select id,nickname,email,role,register_time,aevter,phone from users where id = "%s"' % (uid)
        res = DB.select(select_sql)
        if(res):
            select_sql = 'select jd_id from jd_collect where user_id = "%s"' % (uid)
            collect_data = DB.select(select_sql)
            collections = []
            if(collect_data):
                for i in range(len(collect_data)):
                    collections.append(collect_data[i][0])
            (uid, nickname, email, role, register_time, aevter, phone) = res[0]
            data = {
                'user_id': uid, 
                'nickname': '' if(nickname == None) else nickname,
                'email': email,
                'role': role,
                'register_time': str(register_time),
                'aevter': '' if(aevter == None) else aevter,
                'phone': '' if(phone == None) else phone,
                'collections': collections
            }
            return json.dumps(data)
        else:
            return 'No such user_id!'
    except Exception as e:
        print('[Error]:', e)
        return 'Fail!'

if __name__ == "__main__":
    print('This is feedback api.')