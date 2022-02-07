import hashlib
import json
import random

from DataBase import Database


def generate_identifying_code():
    rand_int = [str(random.randrange(0, 10)) for i in range(3)]
    rand_char = [chr(random.randrange(65, 91)) for i in range(3)]
    code = rand_int + rand_char
    random.shuffle(code)
    return "".join(code)

def generate_token():
    code = generate_identifying_code()
    md5 = hashlib.md5()
    md5.update(code.encode('utf-8'))
    return md5.hexdigest()

def login(email, password):
    DB = Database('appdata')
    select_sql = 'select count(*) from users where email = "%s" and password = "%s"' % (email, password)
    flag = DB.select_fetchone(select_sql)[0]
    if(flag):
        select_sql = 'select id from users where email = "%s" and password = "%s"' % (email, password)
        uid = DB.select_fetchone(select_sql)[0]
        token = generate_token()
        sql = 'update users set token = "%s" where email = "%s"' % (token, email)
        DB.update(sql)
        select_sql = 'select id,nickname,email,role,register_time,aevter,phone from users where id = "%s"' % (uid)
        res = DB.select(select_sql)
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
            'token': token,
            'collections': collections
        }
        return json.dumps(data)
    else:
        return '{}'

def check_token(email, token):
    DB = Database('appdata')
    sql = 'select count(*) from users where email = "%s" and token = "%s"' % (email, token)
    return DB.select_fetchone(sql)[0] != 0

def logout(email, token):
    if check_token(email, token):
        DB = Database('appdata')
        sql = 'update users set token = "" where email = "%s"' % email
        DB.update(sql)
        return True
    else:
        return False

if __name__ == "__main__":
    DB = Database('appdata')
    select_sql = 'select id from users where email = "%s" and password = "%s"' % ('1', '2')
    print(DB.select_fetchone(select_sql)[0])
