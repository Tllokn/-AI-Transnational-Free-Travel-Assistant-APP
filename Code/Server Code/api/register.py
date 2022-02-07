import random
import smtplib
import time
from email.header import Header
from email.mime.text import MIMEText
from email.utils import formataddr, parseaddr

from DataBase import Database


# 生成6位验证码
def generate_identifying_code():
    rand_int = [str(random.randrange(0, 10)) for i in range(3)]
    rand_char = [chr(random.randrange(65, 91)) for i in range(3)]
    code = rand_int + rand_char
    random.shuffle(code)
    return "".join(code)

def format_addr(s):
    name, addr = parseaddr(s)
    return formataddr((Header(name, 'utf-8').encode(), addr))

def sent_code_email(receiver, code, language='', user='xmu_fxsn@163.com', pwd='Admin000'):
    mail_host = "smtp.163.com"
    # 信息
    if(language == 'zh-CHS' or language == ''):
        content = """
                亲爱的用户：
                自强不息，止于至善
                人生没有停靠站，现实永远是一个出发点。无论何时何地，不能放弃，只有保持奋斗的姿态，才能证明生命的存在。
                生命不息，在任何一种博大的辉煌之后，都掩藏着许多鲜为人知的艰难的奋斗。
                前人已为我们指明了实现梦想的道路--奋斗，我们怎可不走呢？莘莘学子为了实现大学梦想，挑灯夜战，不懈奋斗；芸芸祖国建设者为了实现强国梦，舍己为国，不懈奋斗；碌碌大众为了实现富足梦，早出晚归，不懈奋斗。奋斗吧，追梦之路上不懈奋斗最终，展开双臂，拥抱美梦成真的曙光。
                验证码为:{}
            """.format(code)
    elif(language == 'ja'):
        content = """
                親愛なるユーザー：
                自彊してやまず,至善にとどまった
                人生には停止する场所がなく、现実は永远に出発点である。いつでもどこでも、あきらめずに生きていく姿势が、生命の存在を证明する。
                生命の绝えないで、いかなる1种の大きい辉きの后で、すべてすべて隠されていますたくさんの人の知らない所の苦しい奋闘。
                先人はすでに私たちに梦想を実现する道を示しました——奋闘して、私たちはどうして歩きますか?来学は大学の梦を実现するために、夜戦を挑発し、奋闘する。中国は、强い国の梦を実现するために、自分を舍てて、たゆまず努力します;くだらなく大衆は豊かな夢を実現するために早く夜遅く帰ってくる。努力しましょう、梦を追いかける道にたゆまず奋闘して最后に、両腕を広げて、美梦の真の光を抱拥します。
                検証コードは:{}
            """.format(code)
    else:
        content = """
                {}
            """.format(code)
    message = MIMEText(content, "plain", "utf-8")
    message["Form"] =  format_addr('Lines <%s>' % user)
    message["To"] = receiver
    message["Subject"] = '自由旅行'
    # 发送
    smtpObj = smtplib.SMTP_SSL(mail_host, 465)
    smtpObj.login(user, pwd)
    smtpObj.sendmail(user, receiver, message.as_string())

def create_user(user_data, language=''):
    DB = Database('appdata')
    user_email = user_data["email"]
    # 检测邮箱是否已经存在
    try:
        sql = 'select * from users where users.email = "%s"' % user_email
        if DB.select(sql):
            return False
    except Exception as e:
        print('[Error]:', e)
        return False
    code = generate_identifying_code()
    try:
        select_sql = 'select email from codes where codes.email = "%s"' % user_email
        sent_code_email(user_email, code, language)
        if(DB.select(select_sql)):
            sql = 'update codes set code = "%s" where email = "%s"' % (code, user_email)
            DB.update(sql)
        else:
            sql = 'insert into codes (code, email) values ("%s", "%s")' % (code, user_email)
            DB.insert(sql)
    except Exception as e:
        print('[Error]:', e)
    return True

def validate(user_data):
    DB = Database('appdata')
    user_email = user_data['email']
    sql = 'select code from codes where codes.email = "%s"' % user_email
    code = DB.select_fetchone(sql)[0]
    # 验证成功
    if(code == user_data["code"]):
        insert_user_data(user_data)
        try:
            sql = 'delete from codes where email = "%s"' % user_email
            DB.delete(sql)
        except Exception as e:
            print('[Error]:', e)
        return True
    # 验证失败
    else:
        return False

def insert_user_data(user_data):
    DB = Database('appdata')
    user_email = user_data['email']
    user_password = user_data['password']
    sql = 'SELECT COUNT(id) FROM users;'
    try:
        number = DB.select(sql)[0][0]
        new_number = 'U' + str(number + 1).zfill(9)
    except Exception as e:
        print(e); return
    new_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
    sql = 'insert into users (id, email, password, role, register_time) values ("%s", "%s", "%s", "regular", "%s")' % (new_number, user_email, user_password, new_time)
    try:
        DB.insert(sql)
    except Exception as e:
        print(e); return 