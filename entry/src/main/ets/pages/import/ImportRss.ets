import promptAction from '@ohos.promptAction';
import { rssRequest, RssXmlResult } from '../../net/http';

import { RssItem, RssObject } from '../../rssObject';
import router from '@ohos.router';
import distributedKVStore from '@ohos.data.distributedKVStore';
import { kvManager } from '../../entryability/EntryAbility';
import { DbUtil } from '../../utils/db_util';

@Entry
@Component
struct ImportRssPage {
  @State isSearching: boolean = false
  @State urlText: string = ''
  @State resultText: RssObject | null = null
  @State errorResultText: string | null = null

  build() {
    Column() {
      //标题
      titleBar()

      //订阅输入框
      this.inputRss()

      this.result()

      Blank()
    }
  }

  doSearch() {


    if (this.urlText.trim().length == 0 ||
    !this.urlText.startsWith("http")) {
      //校验url

      promptAction.showToast({ message: "请输入正确的URL" })
      return
    }
    this.isSearching = true
    console.debug('doSearch', this.urlText)
    rssRequest(this.urlText.trim())
    // rssRequest('https://www.pnas.org/action/showFeed?type=searchTopic&taxonomyCode=type&tagCode=twip')
      .then(result => {
        if (result.isSuccess) {

          this.resultText = result.result !
        } else {
          this.errorResultText = result.msg
        }
      })
      .catch(e => promptAction.showToast({ message: e }))
      .finally(() => this.isSearching = false)
  }

  @Builder inputRss() {
    Row({ space: 10 }) {
      TextInput({ placeholder: '请输入订阅URL' })
        .onChange((text) => {
          this.urlText = text
          console.debug(text)
        })
        .placeholderFont({ size: 14 })
        .fontSize(14)
        .enabled(!this.isSearching)
        .onSubmit(() => {
          this.doSearch()
        })
        .layoutWeight(1)

      //submit
      Button({ type: ButtonType.Capsule, stateEffect: true }) {
        Row() {
          if (this.isSearching) {
            LoadingProgress().width(20).height(20)
          } else {
            Text('搜索').fontSize(12).fontColor(0xffffff)
          }
        }.alignItems(VerticalAlign.Center)
      }
      .backgroundColor($r('app.color.accent_color'))
      .onClick(() => {
        this.doSearch()
      })
      .width(60).height(32)
    }
    .padding(15)
    .width('100%')
  }

  //搜索结果
  @Builder result() {
    Scroll() {
      if (this.resultText != null) {
        Column({ space: 5, }) {

          Text((this.resultText?.title ?? '').toString()).fontColor(Color.Black).fontSize(20)
          Text((this.resultText?.describe ?? '').toString()).fontColor(Color.Gray).fontSize(13)

          Row() {
            Blank()
            //submit
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Text('添加').fontSize(12).fontColor(0xffffff)
            }
            .backgroundColor($r('app.color.accent_color'))
            .onClick(() => {
              this.saveToCache(this.resultText)
              router.replaceUrl({ url: 'pages/Main', params: this.resultText?.title })
            })
            .width(60).height(32)
          }
          .padding(10)
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
      } else if (this.errorResultText != null) {
        Text((this.errorResultText ?? '').toString()).fontSize(13)
      } else {

      }


    }
    .padding(18)
    .width('100%')

  }

  saveToCache(obj: RssObject) {
    try {
      let context = getContext(this)
      const kvManagerConfig = {
        context: context,
        bundleName: 'com.cheercola.rssfeeder'
      }

      const options = {
        createIfMissing: true, // 当数据库文件不存在时是否创建数据库，默认创建
        encrypt: false, // 设置数据库文件是否加密，默认不加密
        backup: false, // 设置数据库文件是否备份，默认备份
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION, // 设置要创建的数据库类型，默认为多设备协同数据库
        securityLevel: distributedKVStore.SecurityLevel.S2 // 设置数据库安全级别
      }
      DbUtil.insertRssData(getContext(this), obj.title??'', obj.link??'', obj.logo??'', obj.describe??'')
      // storeId为数据库唯一标识符
      kvManager.getKVStore<distributedKVStore.SingleKVStore>('storeId', options, (err, kvStore) => {
        if (err) {
          console.error(`Failed to get KVStore. Code:${err.code},message:${err.message}`);
          return;
        }
        console.info('Succeeded in getting KVStore.');
        // 进行相关数据操作
        kvStore.put(obj.link??'', JSON.stringify(obj));
      });
    } catch (e) {
      console.error(`An unexpected error occurred. Code:${e.code},message:${e.message}`);
    }
  }
}


@Builder function titleBar() {
  Row(){
    Image($r('app.media.back'))
      .size({width:25,height:25}).onClick(()=>{
      router.back()
    })
    Text('添加订阅')
      .height(48)
      .padding({ left: 18 })

    Blank()
  }
  .alignItems(VerticalAlign.Center)
  .padding({left:15})
  .width('100%')

}



