import xml from '@ohos.xml';
import util from '@ohos.util'; // 需要使用util模块函数对文件编码
import { DbHelper } from '../../utils/Dbhelper'
import { RssItem, RssObject } from '../../rssObject';
import { RssDbObject } from '../../models/RssDbModel';
import { CommonDataSource } from '../../utils/CommonDataSource';
import ArrayList from '@ohos.util.ArrayList';

const TAG = 'MyRssViewModel'
///我的订阅
@Observed
export class MyRssViewModel {

  loading = true
  // rssData:RssDbObject[] = new Array(30).fill({group:"111",items:new Array(20).fill({title:'1'})})
  rssData: RssDbObject[] = []
  curIndex: number = 0
  dataSource: CommonDataSource<RssObject>

  updateCurrentIndex(index: number = 0) {
    this.curIndex = index;
    this.dataSource.setData(this.rssData[this.curIndex].items)
  }

  // 判断本地数据库是否有全部订阅
  // 读取数据库
  // 否则读取本地文件，添加到本地
  async loadDataFromDb(context: Context) {
    const dbRssData = await  DbHelper.queryAllRssData(getContext(this))
    if (dbRssData.length == 0) {
      //本地数据不存在，从raw文件添加数据
      this.rssData = await this.loadFromRawFile(context)
    } else {
      this.rssData = dbRssData
    }
    this.dataSource = new CommonDataSource(this.rssData[this.curIndex].items)
    this.loading = false
  }

  async loadFromRawFile(context: Context): Promise<RssDbObject[]> {
    console.log(TAG,'loadFromRawFile start')
    let resourceManager = context.resourceManager;
    let rawFile = await resourceManager.getRawFileContent('feeds-zh.opml')
    let textDecoder = util.TextDecoder.create('UTF-8');
    let rawContent: string = textDecoder.decodeWithStream(rawFile);

    const rssObjects = await this.parseXml(rawContent)
    DbHelper.insertRssData(context, ...rssObjects)
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
    console.log(TAG,'loadFromRawFile end,length:',result.length)
    return result
  }


  ///解析xml
  parseXml(xmlContent: string): Promise<RssObject[]> {
    console.log(TAG,'parseXml start')
    return new Promise((resolve) => {
      let textEncoder = new util.TextEncoder();
      let arrBuffer = textEncoder.encodeInto(xmlContent); // 对数据编码，防止包含中文字符乱码
      let that = new xml.XmlPullParser(arrBuffer.buffer, 'UTF-8');
      let str = '';
      let outlines = new Array<RssObject>();
      let outline: RssObject;
      let group: string = '';
      let depth = 0;
      //name代表了当前事件类型
      //value为当前解析的深度
      function tokenFunc(name, value) {
        depth = value.getDepth()
        str = name + ' : ' + value.getDepth()
        switch (name) {
          case xml.EventType.START_TAG:
            console.info('XmlPullParser', '标签开始:' + str);
            break;
          case xml.EventType.END_TAG:
            console.info('XmlPullParser', '标签结束:' + str);
            if (outline && depth == 4) {
              outlines.push(outline)
            }

            break
          case xml.EventType.END_DOCUMENT:
            console.info('XmlPullParser', '解析结束:' + str);
            console.log(TAG,'parseXml end')
            resolve(outlines)
            break
        }
        console.info('XmlPullParser', 'token:' + str);
        return true;
      }

      function tagFunc(name, value) {
        str = name + value;
        console.info('XmlPullParser', 'tag:' + str);
        if (name == 'outline') {
          outline = new RssObject()
          outline.group = group
        }
        return true;
      }

      function attFunc(name, value) {
        str = name + ' ' + value;
        console.info('XmlPullParser', 'att:' + str);
        if (name == 'title') {
          if (depth == 2) {
            group = value
            outline.group = group
          } else {
            outline.title = value
          }
        }
        if (name == 'xmlUrl') {
          outline.link = value
        }

        return true;
      }

      let options = {
        supportDocType: true,
        ignoreNameSpace: true,
        tagValueCallbackFunction: tagFunc,
        attributeValueCallbackFunction: attFunc,
        tokenValueCallbackFunction: tokenFunc,
      };
      that.parse(options);
    })
  }
}
