import { RssItem, RssObject } from '../../../rssObject'
import { CommonDataSource } from '../../../utils/CommonDataSource'
import { CommonUtil } from '../../../utils/CommonUtil'
import { RssListViewModel } from './RssListViewModel'

@Component
export struct RssListByGroup {
  rssGroup: RssObject[] = []
  @State viewModel: RssListViewModel = new RssListViewModel()

  build() {
    Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
      //@Link子组件从父组件初始化@State的语法为Comp({ aLink: this.aState })。
      // 同样Comp({aLink: $aState})也支持。
      ListViewContainer({
        viewModel: $viewModel,
      })
        .margin({ top: 10 })
    }
    .onRefreshing(() => {
      this.viewModel.refresh()
    })
    .height('100%')
  }

  aboutToAppear() {
    this.viewModel.refresh(this.rssGroup)
  }
}

@Component
struct ListViewContainer {
  @Link viewModel: RssListViewModel

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      if (!this.viewModel.isSuccess) {
        Text('请求失败').textAlign(TextAlign.Center)
      } else if (this.viewModel.isEmpty) {
        Text('暂无数据').textAlign(TextAlign.Center)
      } else {
        List({ space: 12, initialIndex: 0 }) {
          LazyForEach(new CommonDataSource(this.viewModel.rssList), (item: RssItem, index) => {
            ListItem() {
              NavRouter() {
                MainPageListItem({ item: item })
                // RssDetailPage({item:item})

              }
            }.margin({ left: 10, right: 10 })
          }, (item: RssItem) => item.title || '')
        }
        .width('100%')
        .height('100%')

      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct MainPageListItem {
  item: RssItem;
  private index: number = 0;

  build() {
    Column({ space: 15 }) {
      Text('' + this.item.title)
        .maxLines(2)
        .fontSize(16)
        .fontWeight(500)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
      if (this.item.describe?.length > 0) {
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
    .backgroundColor($r('app.color.start_window_background'))
    .border({ style: BorderStyle.Solid, color: Color.Gray, width: 0.2, radius: 10 })

  }
}
