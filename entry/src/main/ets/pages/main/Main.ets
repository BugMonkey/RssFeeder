import router from '@ohos.router';
import { RssDbModel } from '../../models/RssDbModel';
import { MainViewModel } from './MainViewModel';

@Entry
@Component
struct MainPage {
  @State viewModel: MainViewModel = new MainViewModel()

  @Builder NavigationMenus() {
    NavRouter() {
      Row() {
        Text(`添加`)
          .fontSize(14)
          .textAlign(TextAlign.Start)
          .onClick(() => {
            router.pushUrl({ url: 'pages/import/ImportRss' },)
          })
      }
      .borderRadius(24)

    }
  }

  build() {
    Navigation() {
      Stack() {
        if (!this.viewModel.inited) {
          LoadingProgress().color($r('app.color.accent_color')).size({ width: 30, height: 30 })
        } else {
          Refresh({ refreshing: $$this.viewModel.isRefreshing }) {
            ListViewContainer({ list: this.viewModel.rssList })
              .margin({ top: 10 })
          }
          .onRefreshing(() => {
            this.viewModel.rssList = []
            this.viewModel.loadData()
          })
          .height('100%')
        }

      }
      .width('100%')
      .height('100%')

    }
    .menus(this.NavigationMenus())
    .title('我的订阅')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)

  }

  onPageShow() {
    this.viewModel.loadData();
  }
}

@Component
struct ListViewContainer {
  @Prop list: Array<RssDbModel>

  build() {
    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      if (this.list.length == 0) {
        Text('暂无数据').textAlign(TextAlign.Center)
      } else {
        List({ space: 12, initialIndex: 0 }) {
          ForEach(this.list, (item, index) => {
            ListItem() {
              NavRouter() {
                MainPageListItem({ item: item })
                NavDestination() {
                  Text(item.name)
                }.title("NavDestinationTitle" + item)
              }
            }.margin({ left: 10, right: 10 })
          }, item => item.id)
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
  item: RssDbModel;
  private index: number = 0;

  build() {
    Column({ space: 10 }) {
      Text('' + this.item.name)
        .fontSize(16)
        .fontWeight(500)
        .textAlign(TextAlign.Center)
      Text('' + this.item.description)
        .fontSize(12)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(10)
    .backgroundColor($r('app.color.start_window_background'))
    .border({ style: BorderStyle.Solid, color: Color.Gray, width: 0.2, radius: 10 })

  }
}
