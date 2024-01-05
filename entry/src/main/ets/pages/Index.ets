import router from '@ohos.router'
@Entry
@Component
struct Index {
  @State message: string = 'RssFeeder'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontStyle(FontStyle.Italic)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent_color'))
      }
      .width('100%')
    }
    .height('100%')
    .onAppear(()=>{
      setTimeout(()=>{
        router.replaceUrl({
          url: 'pages/main/Main' // 目标url
        }, router.RouterMode.Single,)
      },3_000)
    })
  }


}

