import router from '@ohos.router';
import { FixSizeWrap } from '../../components/SizeWrap';
import { RssItem, RssObject } from '../../rssObject';
import { CommonDataSource } from '../../utils/CommonDataSource';
import { MyRssViewModel } from './MyRssViewModel';


/**
 * 我的订阅
 */
@Entry
@Component
struct MyRss {

  @State viewModel:MyRssViewModel = new MyRssViewModel()
  // @State @Watch('onRssPickedChange') pickedRss: Object[] = []
  @StorageLink('rss') @Watch('onRssPickedChange') pickedRss:RssObject[] = new Array<RssObject>()

  //控制左侧菜单内容
  leftListController: Scroller = new Scroller()
  //控制右侧分组内容
  rightListController: Scroller = new Scroller()
  //期望的右侧尺寸
  @State childSize: {
    width: number,
    height: number
  } = { width: 0, height: 0 }



  @Builder itemHead(text: string) {
    Text(text)
      .fontSize(16)
      .backgroundColor(0xAABBCC)
      .width("100%")
      .padding(10)
  }

  onRssPickedChange(propName: string) {
    let rssStr = this.pickedRss.map(e => {
      return e['title'] || ''
    }).join(',')
    console.log('onRssPickedChange : ', rssStr)
  }



  build() {
    Column() {
      titleBar()
      if (this.viewModel.loading){
        LoadingProgress().size({width:40,height:40}).height('100%')
      }else {
        if (this.viewModel.rssData.length > 0){
          Row() {
            Scroll(this.leftListController) {
              Column() {

                ForEach(this.viewModel.rssData.map(e => e.group), (item, index) => {


                  Text(`${item} `)
                    .padding(10)

                    .onClick(() => {

                      this.viewModel.updateCurrentIndex(index)

                    })
                    .width(100)
                    .backgroundColor(this.viewModel.curIndex == index ? $r('app.color.accent_color') : Color.Transparent)


                    .height(50)
                })
              }
              .width(100)
            }
            .scrollBar(BarState.Off)
            .width(100)


              List({ space: 0, scroller: this.rightListController }) {
                LazyForEach(this.viewModel.dataSource, (project:RssObject) => {
                  ListItem() {
                    Row() {
                      Text(project.title)

                        .height(50).fontSize(16)
                        .textAlign(TextAlign.Center)
                      Blank()
                      Checkbox()
                        .select(this.pickedRss.findIndex(e=>project.title == e.title) >= 0)
                        .selectedColor($r('app.color.accent_color'))
                        .onChange((value: boolean) => {
                          if (value) {
                            this.pickedRss.push(project)
                          } else {
                            const removeIndex = this.pickedRss.findIndex(e=>project.title == e.title)
                            if (removeIndex >= 0) {
                              this.pickedRss.splice(removeIndex, 1)
                            }

                          }
                          console.log(this.pickedRss.length.toString());
                        })
                    }
                    .padding({ left: 10, right: 10 })
                    .width(this.childSize.width)
                  }
                }, (item:RssObject) => item.link+item.title)
              }
              .edgeEffect(EdgeEffect.Spring)
              .onReachStart(() => {
                console.log('onReachStart')
              })
              .onReachEnd(() => {
                console.log('onReachEnd')
              })
              .sticky(StickyStyle.Header | StickyStyle.Footer)
              .onScrollIndex((start, end) => {
                console.log(start.toString(), end.toString())
              })
              .width(this.childSize.width)
              .height(820)

              .flexGrow(1)

              .onAreaChange((_, newValue) => {
                this.childSize = { width: newValue.width as number, height: newValue.height as number }
                console.log('onAreaChange',this.childSize.width.toString(),this.childSize.height.toString())
              })

          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
          .height('100%')
        }

      }

    }
    .height('100%')
    .width('100%')
  }

  onPageShow(){
    this.viewModel.loadDataFromDb(getContext(this))
  }
}

@Builder function titleBar() {
  Row() {
    Image($r('app.media.back'))
      .size({ width: 25, height: 25 }).onClick(() => {
      router.back()
    })
    Text('我的订阅')
      .height(48)
      .padding({ left: 18 })

    Blank()

    Text('添加')
      .fontColor($r('app.color.secondary_color'))
      .fontSize(14)
      .height(48)
      .padding({ right: 18 })
      .onClick(()=>{
        router.pushUrl({url:'pages/import/ImportRss'})
      })
  }
  .alignItems(VerticalAlign.Center)
  .padding({ left: 15 })
  .width('100%')

}