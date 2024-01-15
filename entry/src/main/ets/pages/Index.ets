import router from '@ohos.router'
@Entry
@Component
struct Index {
  @State message: string = 'RssFeeder'

  build() {
    Flex(){
      Image($r('app.media.splash_screen')).objectFit(ImageFit.Contain)
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

