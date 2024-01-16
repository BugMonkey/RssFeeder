import router from '@ohos.router';
import { RssDbObject } from '../../models/RssDbModel';
import { RssItem, RssObject } from '../../rssObject';
import { DbHelper } from '../../utils/Dbhelper';
import { MainViewModel } from './MainViewModel';
import { RssListByGroup } from './rss_group/RssListByGroup';

AppStorage.SetOrCreate('rss', [])
let storage = new LocalStorage({ 'rss': [] })

@Entry(storage)
@Component
struct MainPage {
  @State viewModel: MainViewModel = new MainViewModel()
  //我的订阅
  @StorageLink('rss') rssStore: RssObject[] = []
  @State groups: string[] = []
  @State items: RssObject[] = []
  @State rssGroup: RssDbObject[] = []
  @State currentIndex: number = 0

  onTabContentPageShow:()=>void = ()=>{}


  rssStoreChange() {
    let groups: {
      group: string,
      items: RssObject[]
    }[] = []
    for (const item of this.rssStore) {
      const key = item.group
      let index = groups.findIndex(e => e.group == key)
      if (index < 0) {
        groups.push({ group: key, items: [item] })
      } else {
        groups[index].items.push(item)
      }
    }
    // this.groups = [...groups.values()].map((e)=>e.group)
    // this.item= [...groups.values()].map((e)=>e.group)
    this.rssGroup = groups
  }

  build() {
    Scroll(){
      Column() {
        Row() {
          this.title()
          Blank()
          Text(`我的订阅`)
            .fontColor($r('app.color.secondary_color'))
            .fontSize(12)
            .textAlign(TextAlign.Start)
            .onClick(() => {
              router.pushUrl({ url: 'pages/my_rss/MyRss' },)
            })
        }.padding({left:10,right:20}).width('100%')
        Stack() {
          if (!this.viewModel.inited) {
            LoadingProgress().color($r('app.color.accent_color')).size({ width: 30, height: 30 })
          } else {
            if (this.rssGroup.length > 0) {
              Flex({direction:FlexDirection.Column}){
                Row() {
                  ForEach(this.rssGroup, (rssGroupItem: RssDbObject, index) => {
                    this.tabBarBuilder(rssGroupItem.group, index)
                  },(group, index) => group.group + index)
                }
                .height(60)

                Swiper() {
                  ForEach(this.rssGroup, (rssGroupItem, index) => {
                    RssListByGroup({ mCurrentTabIndex: this.currentIndex, group: rssGroupItem.group, index: index })
                  }, (group, index) => group.group + index)
                }
                .indicator(false)
                .loop(false)
                .effectMode(EdgeEffect.None)
                .onChange((index: number) => {
                  this.currentIndex = index
                })
                .height('100%')
              }

            } else {
              Text('暂无订阅，请先添加').fontColor($r('app.color.secondary_color'))
                .onClick(() => {
                  router.pushUrl({ url: 'pages/my_rss/MyRss' },)
                })
            }
          }

        }
        .width('100%')
        .height('100%') //这是scroll的100%
      }
    }
    .scrollBar(BarState.Off)
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
    .scrollable(this.rssGroup.length > 0 ? ScrollDirection.Vertical : ScrollDirection.None)
  }

  @Builder title() {
    Image($r('app.media.label_text')).objectFit(ImageFit.Auto).height(40)
  }

  @Builder tabBarBuilder(name: string, index: number) {
    Column({ space: 5 }) {
      Text(name)
        .fontColor(index == this.currentIndex ? $r('app.color.secondary_color') : $r('app.color.accent_color'))
        .textAlign(this.rssGroup.length > 1 ? TextAlign.Center : TextAlign.Start)
        .padding({ left: 15, right: 15 })
        .width(`${100 / Math.min(this.rssGroup.length, 4)}%`)
      if (this.rssGroup.length > 1) {
        Shape() {
          Rect().width(30).height(4).radius(4).fill($r('app.color.secondary_color'))
        }
        .visibility(index == this.currentIndex ? Visibility.Visible : Visibility.Hidden)

      }
    }
    .onClick(()=>this.currentIndex = index)

  }

  onPageShow() {
    // this.viewModel.loadData();
    // this.viewModel.loadFromRawFile(getContext(this));
    this.rssStoreChange()
    //更新缓存
    DbHelper.updateMyRss(getContext(this), this.rssStore)

  }

  aboutToAppear() {
    this.initStorage()
  }

  //初始化缓存
  initStorage() {
    DbHelper.getMyRssData(getContext(this)).then((result) => {
      this.rssStore = result
    })
  }
}

