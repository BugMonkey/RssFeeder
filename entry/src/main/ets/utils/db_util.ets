import relationalStore from '@ohos.data.relationalStore'; // 导入模块
import { RssDbObject } from '../models/RssDbModel';

export class DbUtil {
  static STORE_CONFIG = {
    name: 'RdbTest.db', // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
  }

  static getDb(context: Context, action: (RdbStore) => void) {

    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS RSS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, LINK TEXT NOT NULL, DESCRIPTION TEXT NOT NULL,LOGO TEXT NOT NULL)'; // 建表Sql语句

    relationalStore.getRdbStore(context, DbUtil.STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Succeeded in getting RdbStore.`);
      store.executeSql(SQL_CREATE_TABLE); // 创建数据表
      action(store)
    })

  }

  // 插入rss数据
  static insertRssData(context: Context, name: string, link: string, logo: string, description: string) {
    this.getDb(context, (store) => {
      store.insert('RSS', { 'NAME': name,
        'LINK': link, 'DESCRIPTION': description, 'LOGO': logo }, (err, rowId) => {
        if (err) {
          console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`Succeeded in inserting data. rowId:${rowId},name:${name}}`);
      })
    })
  }


  // 查询所有添加的数据
  static async queryAllRssData(context: Context): Promise<Array<RssDbObject>> {
    return new Promise((resolve, reject) => {
      let result = []
      this.getDb(context, (store) => {
        let predicates = new relationalStore.RdbPredicates('RSS');
        store.query(predicates, ['ID', 'NAME', 'LOGO', 'LINK', 'DESCRIPTION'], (err, resultSet) => {
          if (err) {
            console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
            reject(err)
            return;
          }
          // const columnNames = resultSet.columnNames
          // const columnCount = resultSet.columnCount
          resultSet.goToFirstRow()
          while (!resultSet.isEnded) {

            const rss = new RssDbObject(
              resultSet.getLong(resultSet.getColumnIndex("ID")),
              resultSet.getString(resultSet.getColumnIndex("NAME")),
              resultSet.getString(resultSet.getColumnIndex("LOGO")),
              resultSet.getString(resultSet.getColumnIndex("LINK")),
              resultSet.getString(resultSet.getColumnIndex("DESCRIPTION"))
            )
            result.push(rss)
            resultSet.goToNextRow();
          }
          resultSet.close()
          resolve(result)
        })
      })
    });

  }
}