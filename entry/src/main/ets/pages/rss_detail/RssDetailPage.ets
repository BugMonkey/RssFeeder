import { RssDbObject } from '../../models/RssDbModel'
import { RssDetailViewModel } from './RssDetailViewModel'

@Entry
@Component
export struct RssDetailPage {
  item: RssDbObject = new RssDbObject(1, '1', 'link', 'logo', 'describe')
  @State private viewModel: RssDetailViewModel = new RssDetailViewModel()

  build() {
    NavDestination() {
      Flex()
        .size({ width: '100%', height: '100%' })
        .backgroundColor(Color.White)
    }
    .title(this.item.name)

  }

  onPageShow() {
    this.viewModel.loadRssLink(this.item.link)
  }
}