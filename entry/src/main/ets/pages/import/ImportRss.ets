import promptAction from '@ohos.promptAction';
import { rssRequest, RssXmlResult } from '../../net/http';

import { RssItem, RssObject } from '../../rssObject';
import router from '@ohos.router';
import distributedKVStore from '@ohos.data.distributedKVStore';
import { kvManager } from '../../entryability/EntryAbility';
import { DbUtil } from '../../utils/db_util';
import ArrayList from '@ohos.util.ArrayList';
import { CommonDataSource } from '../../utils/CommonDataSource';
import { FixSizeWrap } from '../../components/SizeWrap';

@Entry
@Component
struct ImportRssPage {
  @State isSearching: boolean = false
  @State urlText: string = ''
  @State resultText: RssObject | null = null
  @State errorResultText: string | null = null
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AddRssConfirmDialog({
      rssObj:this.resultText,
      cancel: this.onCancel,
      confirm: this.onAccept,
    }),
    alignment: DialogAlignment.Default,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })
  onCancel() {
    console.info('onCancel is clicked')
  }
  onAccept() {
    console.info('onAccept is clicked')
    // this.saveToCache(this.resultText)
    router.back()
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      //标题
      titleBar()

      //订阅输入框
      this.inputRss()

      this.result()
    }
  }

  doSearch() {
    let fake = new RssObject()
    fake.title = '这是标题'
    fake.link = '这是链接'
    this.resultText = fake
    return
    if(this.urlText.trim().length == 0 ||
    !this.urlText.startsWith("http"))
    {
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
    .padding({ left: 15, right: 15 })
    .width('100%')
  }

  //搜索结果
  @Builder result() {
    Stack() {
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
              this.dialogController.open()
              // this.saveToCache(this.resultText)
              // router.back()
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
  Row() {
    Image($r('app.media.back'))
      .size({ width: 25, height: 25 }).onClick(() => {
      router.back()
    })
    Text('添加订阅')
      .height(48)
      .padding({ left: 18 })

    Blank()
  }
  .alignItems(VerticalAlign.Center)
  .padding({ left: 15 })
  .width('100%')

}

@CustomDialog
struct AddRssConfirmDialog {
  rssObj:RssObject
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void
  build() {
    Column() {

      Column(){
        Text('标题').subTitleStyle()
        TextInput({text:this.rssObj.title||''}).editStyle()
        Text('地址').subTitleStyle()
        TextInput({text:this.rssObj.link||''}).editStyle()
        Text('类型').subTitleStyle()
        TextInput({text:'自定义',placeholder:'请输入类别'}).editStyle()
      }
      .alignItems(HorizontalAlign.Start)
      .margin(20)


      Row(){
        Button('取消').flexGrow(1)
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确认').flexGrow(1)
          .onClick(() => {
            this.controller.close()
            this.confirm()
          }).fontColor($r('app.color.secondary_color')).backgroundColor(0xffffff)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ left: 10,right:10 })
      .width('100%')
    }
  }
}


@Extend(TextInput) function editStyle(){
  .fontSize(14)
  .fontColor(0x333333)
  .backgroundColor(Color.Transparent)
  .borderRadius(1)
  .border({style:{bottom:BorderStyle.Solid,left:BorderStyle.Dashed},width: { left: 0, right: 0, top: 0, bottom: 0.5 },color:$r('app.color.accent_color')})
  .height(40)
  .padding({left:4,right:4,top:2,bottom:2})
  .caretColor($r('app.color.secondary_color'))
  .margin({bottom:10})

}
@Extend(Text) function subTitleStyle(){
  .fontSize(11)
  .fontColor($r('app.color.secondary_color'))
}

