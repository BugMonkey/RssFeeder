
import promptAction from '@ohos.promptAction';
import { rssRequest } from '../net/http';

@Entry
@Component
struct ImportRssPage {
  @State isSearching: boolean = false
  @State urlText: string = ''
  @State resultText: string = ''

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
    console.debug('doSearch',this.urlText)
    rssRequest(this.urlText).then(result => {
      if (result.isSuccess) {
        this.resultText = result.result
      }
    })
      .catch(e=> promptAction.showToast({ message: e }))
      .finally(() => this.isSearching = false)
  }

  @Builder inputRss() {
    Row({ space: 10 }) {
      TextInput({ placeholder: '请输入订阅URL', text: 'https://www.nature.com/nature.rss' })
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
  @Builder  result() {
    Scroll(){
      Column({ space: 5, }) {
        Text(this.resultText).fontSize(13)
      }
      .alignItems(HorizontalAlign.Start)
      .padding(18)
    }
    .width('100%')

  }
}


@Builder function titleBar() {
  Text('添加订阅')
    .height(48)
    .padding({ left: 18 })

}


