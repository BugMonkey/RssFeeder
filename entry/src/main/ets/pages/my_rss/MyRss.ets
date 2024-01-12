import router from '@ohos.router';
import { FixSizeWrap } from '../../components/SizeWrap';
import { RssObject } from '../../rssObject';
import { CommonUtil } from '../../utils/CommonUtil';


/**
 * 我的订阅
 */
@Entry
@Component
struct MyRss {
  @State curIndex: number = 0;
  // @State @Watch('onRssPickedChange') pickedRss: Object[] = []
  @StorageLink('rss') @Watch('onRssPickedChange') pickedRss:RssObject[] = new Array<RssObject>()
  rssData: {group:string,items:RssObject[]}[] = [
    {
      group: '新闻',
      items: [
        {
          title: '喷嚏图卦',
          link: 'https://plink.anyfeeder.com/pentitugua'
        },
        {
          title: 'Daily 每日环球视野',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
      ]
    },
    {
      group: '科技',
      items: [
        {
          title: 'Solidot',
          link: 'https://plink.anyfeeder.com/pentitugua'
        },
        {
          title: '数字尾巴',
          link: 'https://plink.anyfeeder.com/idaily/today'
        },
        {
          title: '36氪',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
        ,
        {
          title: 'cnBeta',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
        ,
        {
          title: 'IT 之家',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
      ]
    },
    {
      group: '知识',
      items: [
        {
          title: '知乎日报',
          link: 'https://plink.anyfeeder.com/pentitugua'
        },
        {
          title: '知乎日报',
          link: 'https://plink.anyfeeder.com/idaily/today'
        },
        {
          title: '人人都是产品经理',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
        ,
        {
          title: 'cnBeta',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
        ,
        {
          title: 'IT 之家',
          link: 'https://plink.anyfeeder.com/idaily/today'
        }
      ]
    }
  ]
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
      Row() {
        Scroll(this.leftListController) {
          Column() {

            ForEach(this.rssData.map(e => e.group), (item, index) => {


              Text(`${item} `)
                .padding(10)

                .onClick(() => {

                  this.curIndex = index;

                })
                .width(100)
                .backgroundColor(this.curIndex == index ? $r('app.color.accent_color') : Color.Transparent)


                .height(50)
            })
          }
          .width(100)
        }
        .scrollBar(BarState.Off)
        .width(100)

        FixSizeWrap({ childSize: $childSize }) {
          List({ space: 0, scroller: this.rightListController }) {
            ForEach(this.rssData[this.curIndex].items, (project:RssObject) => {
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
                        project.group = this.rssData[this.curIndex].group
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
            }, item => item.title)
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

        }

      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
    }
    .height('100%')
    .width('100%')

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