import router from '@ohos.router'
@Entry
@Component
struct Index {
  @State message: string = 'RssFeeder'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
    .onAppear(()=>{
      setTimeout(()=>{
        router.replaceUrl({
          url: 'pages/ImportRss' // 目标url
        }, router.RouterMode.Single,)
      },3_000)
    })
  }


}