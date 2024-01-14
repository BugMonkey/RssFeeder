import { RssDbObject } from '../../models/RssDbModel'
import { RssObject } from '../../rssObject'
import { RssDetailViewModel } from './RssDetailViewModel'

@Entry
@Component
export struct RssDetailPage {
  item: RssObject = new RssObject()
  @State private viewModel: RssDetailViewModel = new RssDetailViewModel()

  build() {
    NavDestination() {
      Flex()
        .size({ width: '100%', height: '100%' })
        .backgroundColor(Color.White)
    }
    .title(this.item.title)

  }

  onPageShow() {
    this.viewModel.loadRssLink(this.item.link)
  }
}