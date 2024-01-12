import distributedKVStore from '@ohos.data.distributedKVStore';
import xml from '@ohos.xml';
import util from '@ohos.util'; // 需要使用util模块函数对文件编码
import { kvManager } from '../../entryability/EntryAbility';
import { RssDbObject } from '../../models/RssDbModel'
import { DbUtil } from '../../utils/db_util';
import emitter from '@ohos.events.emitter';

@Observed
export class MainViewModel {
  inited: boolean = true;
  rssList: RssDbObject[] = [new RssDbObject(1,'标题','链接','','')];
  isRefreshing: boolean = false;
  //隐藏标题栏事件
  private hideNavigationBarEvent = {eventId:1};

  observeEvent(){
    var callback = (eventData) => {
      console.info('callback');
    };
    emitter.on(this.hideNavigationBarEvent, callback);
  }

  unObserveEvent(){
    emitter.off(1)
  }


  loadDataFromDb() {
    // this.rssList = []
    DbUtil.queryAllRssData(getContext(this)).then((result) => {
      this.rssList = result
    }).finally(() => {
      setTimeout(() => {
        this.inited = true
        this.isRefreshing = false
      }, 1_000)
    })

    const options = {
      createIfMissing: true, // 当数据库文件不存在时是否创建数据库，默认创建
      encrypt: false, // 设置数据库文件是否加密，默认不加密
      backup: false, // 设置数据库文件是否备份，默认备份
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION, // 设置要创建的数据库类型，默认为多设备协同数据库
      securityLevel: distributedKVStore.SecurityLevel.S2 // 设置数据库安全级别
    }
    // storeId为数据库唯一标识符
    new Promise<void>((resolve) => {
      kvManager.getKVStore<distributedKVStore.SingleKVStore>('storeId', options, async (err, kvStore) => {
        if (err) {
          console.error(`Failed to get KVStore. Code:${err.code},message:${err.message}`);
          return;
        }
        console.info('Succeeded in getting KVStore.');
        // 进行相关数据操作
        let jsonData = await kvStore.get('Proceedings of the National Academy of Sciences: This Week in PNAS')

        try {
          if (jsonData instanceof String) {
            const rssObj = JSON.parse(jsonData as string)
          }

        } catch (e) {
          console.error(e)
        }
      });
      resolve()
    })
  }

  ///从raw文件加载
  loadFromRawFile(context: Context) {
    const global_this = this;
    if (!context) {
      return
    }
    let resourceManager = context.resourceManager;
    resourceManager.getRawFileContent('feeds-zh.opml', (error, value) => {
      if (error != null) {
        console.log("error is " + error.message);
      } else {
        let rawFile = value;
        let textDecoder = util.TextDecoder.create('UTF-8');
        let rawContent = textDecoder.decodeWithStream(rawFile);
        console.error(rawContent);
        this.parseXml(rawContent,(outlines)=>{
          global_this.rssList = outlines;
          setTimeout(() => {
            global_this.inited = true;
            global_this.isRefreshing = false;
          }, 1_000);
        })

      }
    });
  }

  ///解析xml
  parseXml(xmlContent:string,onParseEnd:(array:Array<RssDbObject>)=>void){
    let textEncoder = new util.TextEncoder();
    let arrBuffer = textEncoder.encodeInto(xmlContent); // 对数据编码，防止包含中文字符乱码
    let that = new xml.XmlPullParser(arrBuffer.buffer, 'UTF-8');
    let str = '';
    let outlines = new Array<RssDbObject>();
    let outline: RssDbObject;
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
          if (outline) {
            outlines.push(outline)
          }

          break
        case xml.EventType.END_DOCUMENT:
          console.info('XmlPullParser', '解析结束:' + str);
          onParseEnd(outlines)
          break
      }
      console.info('XmlPullParser', 'token:' + str);
      return true;
    }

    function tagFunc(name, value) {
      str = name + value;
      console.info('XmlPullParser', 'tag:' + str);
      if (name == 'outline') {
        outline = new RssDbObject()
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
          outline.name = value
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
  }
}
