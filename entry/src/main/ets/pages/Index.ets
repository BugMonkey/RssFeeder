import router from '@ohos.router'
import window from '@ohos.window'

@Entry
@Component
struct Index {


  async setSystemBar() {
    let windowClass = await window.getLastWindow(getContext(this))
    //设置状态栏不可见
    await windowClass.setWindowLayoutFullScreen(true)
  }



  aboutToAppear() {
    this.setSystemBar()
  }

  async aboutToDisappear(){
    let windowClass = await window.getLastWindow(getContext(this))
    //设置状态栏不可见
    await windowClass.setWindowLayoutFullScreen(false)
  }

  build() {
    Flex() {
      Image($r('app.media.splash_screen')).objectFit(ImageFit.Contain)
    }
    .height('100%')
    .backgroundColor('#FCFCFC')
    .onAppear(() => {
      setTimeout(() => {
        router.replaceUrl({
          url: 'pages/main/Main' // 目标url
        }, router.RouterMode.Single,)
      }, 3_000)
    })
  }
}

