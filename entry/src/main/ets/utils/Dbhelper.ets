import relationalStore from '@ohos.data.relationalStore'; // 导入模块
import { RssDbObject } from '../models/RssDbModel';
import { RssItem, RssObject } from '../rssObject';

//数据库操作辅助
export class DbHelper {
  static STORE_CONFIG = {
    name: 'AllRss.db', // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
  }

  //获取RSS表（可订阅的rss）
  static getDb(context: Context, action: (RdbStore) => void) {

    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS RSS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL,GROUP TEXT NOT NULL, LINK TEXT NOT NULL, DESCRIPTION TEXT NOT NULL,LOGO TEXT NOT NULL)'; // 建表Sql语句

    relationalStore.getRdbStore(context, DbHelper.STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Succeeded in getting RdbStore.`);
      store.executeSql(SQL_CREATE_TABLE); // 创建数据表
      action(store)
    })

  }

  // 插入可订阅的rss数据
  static insertRssData(context: Context, ...rssObjArray: RssObject[]) {
    this.getDb(context, (store) => {
      rssObjArray.forEach((rssObj) => {
        store.insert('RSS', {
          'NAME': rssObj.title ?? '',
          'GROUP': rssObj.group ?? '',
          'LINK': rssObj.link ?? '',
          'DESCRIPTION': rssObj.describe ?? '',
          'LOGO': rssObj.logo ?? ''
        }, (err, rowId) => {
          if (err) {
            console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
            return;
          }
          console.info(`Succeeded in inserting data. rowId:${rowId},name:${rssObj.title}}`);
        })
      })
    })
  }

  // 查询所有可订阅的数据
  static async queryAllRssData(context: Context): Promise<Array<RssDbObject>> {
    return new Promise((resolve, reject) => {

      this.getDb(context, (store) => {
        let predicates = new relationalStore.RdbPredicates('RSS');
        store.query(predicates, ['ID', 'NAME', 'LOGO', 'LINK', 'DESCRIPTION'], (err, resultSet) => {
          if (err) {
            console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
            reject(err)
            return;
          }
          let rssObjects: RssObject[] = []
          // const columnNames = resultSet.columnNames
          // const columnCount = resultSet.columnCount
          resultSet.goToFirstRow()
          while (!resultSet.isEnded) {

            let rss = new RssObject()
            rss = {
              id: resultSet.getLong(resultSet.getColumnIndex("ID")),
              title: resultSet.getString(resultSet.getColumnIndex("NAME")),
              group: resultSet.getString(resultSet.getColumnIndex("GROUP")),
              logo: resultSet.getString(resultSet.getColumnIndex("LOGO")),
              link: resultSet.getString(resultSet.getColumnIndex("LINK")),
              describe: resultSet.getString(resultSet.getColumnIndex("DESCRIPTION"))
            }
            rssObjects.push(rss)
            resultSet.goToNextRow();
          }
          resultSet.close()
          let result: RssDbObject[] = []
          //按group分组
          for (const obj of rssObjects) {
            let index = result.findIndex((e) => e.group == obj.group)
            if (index == -1) {
              result.push({ group: obj.group, items: [obj] })
            } else {
              result[index].items.push(obj)
            }
          }
          resolve(result)
        })
      })
    });

  }

  // 获取MY_RSS表（我的订阅）
  static getMyRssDbStore(context: Context, action: (RdbStore) => void) {
    const SQL_CREATE_TABLE = 'CREATE TABLE IF NOT EXISTS MY_RSS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL,GROUP TEXT NOT NULL, LINK TEXT NOT NULL, DESCRIPTION TEXT NOT NULL,LOGO TEXT NOT NULL)'; // 建表Sql语句

    relationalStore.getRdbStore(context, DbHelper.STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('DbHelper',`MY_RSS Succeeded in getting RdbStore.`);
      store.executeSql(SQL_CREATE_TABLE); // 创建数据表
      action(store)
    })
  }

  // 覆盖更新我的rss订阅
  static updateMyRss(context: Context, rssObjArray: RssObject[]) {
    const insertArray = rssObjArray.map(rssObj => {
      //转换为db插入值
      const obj = {
        'NAME': rssObj.title ?? '',
        'GROUP': rssObj.group ?? '',
        'LINK': rssObj.link ?? '',
        'DESCRIPTION': rssObj.describe ?? '',
        'LOGO': rssObj.logo ?? ''
      }
      return obj
    })
    this.getMyRssDbStore(context, (store) => {
      let predicates = new relationalStore.RdbPredicates("MY_RSS")
      predicates.isNotNull("NAME")
      store.delete(predicates, (err, rows) => {
        if (err && err.code) {
          console.error('DbHelper', `覆盖更新我的rss订阅失败！ 因为删除失败，Code:${err.code}, message:${err.message}`);
          return
        }
        if (insertArray.length == 0) {
          console.info('DbHelper', `待更新的值为空`)
          return
        }
        store.insert('MY_RSS', insertArray[0], (err, rows) => {
          if (err) {
            console.error('DbHelper', `覆盖更新我的rss订阅失败！ Code:${err.code}, message:${err.message}`);
            return
          }
          console.info('DbHelper', `覆盖更新我的rss订阅成功. rows:${rows}`)
        })
      })

    })
  }

  // 获取我的rss订阅数据
  static getMyRssData(context: Context): Promise<RssItem[]> {
    return new Promise<RssItem[]>((resolve, reject) => {
      DbHelper.getMyRssDbStore(context, (store) => {
        store.query(new relationalStore.RdbPredicates("MY_RSS"), ['ID', 'NAME', 'LOGO', 'LINK', 'DESCRIPTION'], (err, resultSet) => {
          if (err) {
            console.error('DbHelper', `获取我的rss订阅数据失败. Code:${err.code}, message:${err.message}`);
            reject(`Code:${err.code}, message:${err.message}`)
            return;
          }
          let rssObjects: RssObject[] = []
          // const columnNames = resultSet.columnNames
          // const columnCount = resultSet.columnCount
          resultSet.goToFirstRow()
          while (!resultSet.isEnded) {

            let rss = new RssObject()
            rss = {
              id: resultSet.getLong(resultSet.getColumnIndex("ID")),
              title: resultSet.getString(resultSet.getColumnIndex("NAME")),
              group: resultSet.getString(resultSet.getColumnIndex("GROUP")),
              logo: resultSet.getString(resultSet.getColumnIndex("LOGO")),
              link: resultSet.getString(resultSet.getColumnIndex("LINK")),
              describe: resultSet.getString(resultSet.getColumnIndex("DESCRIPTION"))
            }
            rssObjects.push(rss)
            resultSet.goToNextRow();
          }
          resultSet.close()

          resolve(rssObjects)
        })
      })
    })

  }
}