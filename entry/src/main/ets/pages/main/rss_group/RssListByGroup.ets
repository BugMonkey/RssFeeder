import { RssItem, RssObject } from '../../../rssObject'
import { CommonDataSource } from '../../../utils/CommonDataSource'
import { CommonUtil } from '../../../utils/CommonUtil'
import { RssListViewModel } from './RssListViewModel'

@Component
export struct RssListByGroup {
  @StorageLink('rss') @Watch('onRssStoreChange') rssStore: RssObject[] = []
  @Prop @Watch('onTabIndexChange') mCurrentTabIndex: number
  group: string
  index: number
  @State rssGroup: RssObject[] = []
  @State viewModel: RssListViewModel = new RssListViewModel()

  build() {
    // Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
      //@Link子组件从父组件初始化@State的语法为Comp({ aLink: this.aState })。
      // 同样Comp({aLink: $aState})也支持。
      ListViewContainer({
        viewModel: $viewModel,
      })
    // }
    // .onRefreshing(() => {
    //   this.viewModel.refresh(this.rssGroup)
    // })
    // .height('100%')
    // .width('100%')

  }



  aboutToAppear() {
    console.error('aboutToAppear')
    this.rssGroup = this.rssStore.filter(e => e.group == this.group)
    this.viewModel.refresh(this.rssGroup)
  }

  onPageShow(){
    console.error('onPageShow')
  }

  //我的订阅发生变化
  onRssStoreChange() {
    this.rssGroup = this.rssStore.filter(e => e.group == this.group)
  }

  onTabIndexChange() {
    if (this.mCurrentTabIndex == this.index) {
      this.viewModel.refresh(this.rssGroup)
    }
  }
}

@Component
struct ListViewContainer {
  @Link viewModel: RssListViewModel

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      if (this.viewModel.isEmpty) {
        Text('暂无数据').textAlign(TextAlign.Center)
      } else {
        List({ space: 8, initialIndex: 0 }) {
          LazyForEach(this.viewModel.dataSource, (item: RssItem, _) => {
            ListItem() {
              MainPageListItem({ item: item })
            }.margin({ left: 10, right: 10 })
          }, (item: RssItem) => item.url || '')
        }
        .edgeEffect(EdgeEffect.None)
        .width('100%')
        .height('100%')

      }
    }
  }
}

@Component
struct MainPageListItem {
  item: RssItem;
  private index: number = 0;

  build() {
    Column({ space: 10 }) {
      if (this.item.source) {
        Row() {
          Text(this.item.source).fontSize(12).fontWeight(FontWeight.Medium)
          Blank()
          if (this.item.pubDate) {
            Text(this.item.pubDate.toDateString()).fontSize(12)
          }
        }
        .width('100%')

      }


      Text('' + this.item.title)
        .maxLines(2)
        .fontSize(16)
        .fontWeight(500)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
      if (this.item.describe?.length > 0 && this.item.title != this.item.describe) {
        Text(CommonUtil.removeXmlTags(this.item.describe ?? ''))
          .fontSize(12)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
      }

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor(Color.White)
    .border({ style: BorderStyle.Solid, color: Color.Gray, width: 0.2, radius: 10 })
    .shadow({ radius: 2 })
    .margin({ top: 5, bottom: 5 })

  }
}
