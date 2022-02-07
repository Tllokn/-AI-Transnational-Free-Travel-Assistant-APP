import pymysql

class Database():
    def __init__(self, db):
        self.host='localhost'
        self.user='root'
        self.password='1234567'
        self.db= db
        self.port=3306
    def connectMySQL(self):
        conn = pymysql.connect(host=self.host,
                               user=self.user,
                               port=self.port,
                               password=self.password,
                               charset='utf8')
        return conn
    def connectDataBase(self):
        conn = pymysql.connect(host=self.host,
                               user=self.user,
                               port=self.port,
                               password=self.password,
                               db=self.db,
                               charset='utf8')
        return conn
    def createDataBase(self):
        conn = self.connectMySQL()
        sql = "create database if not exists " + self.db
        cur = conn.cursor()
        cur.execute(sql)
        cur.close()
        conn.close()
    def createTable(self, sql):
        conn = self.connectDataBase()
        cur = conn.cursor()
        cur.execute(sql)
        cur.close()
        conn.close()
    def insert(self, sql, *params):
        conn = self.connectDataBase()
        cur = conn.cursor()
        cur.execute(sql, params)
        conn.commit()
        print("success")
        cur.close()
        conn.close()
    def update(self, sql, *params):
        conn = self.connectDataBase()
        cur = conn.cursor()
        cur.execute(sql, params)
        conn.commit()
        cur.close()
        conn.close()
    def delete(self, sql, *params):
        conn = self.connectDataBase()
        cur = conn.cursor()
        cur.execute(sql, params)
        conn.commit()
        cur.close()
        conn.close()
    def select(self, sql):
        conn = self.connectDataBase()
        cur = conn.cursor()
        try:
            cur.execute(sql)
            conn.commit()
            results = cur.fetchall()
            return results
        except:
            return None
        cur.close()
        conn.close()
    def select_fetchone(self, sql):
        conn = self.connectDataBase()
        cur = conn.cursor()
        try:
            cur.execute(sql)
            conn.commit()
            results = cur.fetchone()
            return results
        except:
            return None
        cur.close()
        conn.close()

if __name__ == "__main__":
    print('This is a database module.')
    