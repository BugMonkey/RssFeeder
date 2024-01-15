@Component
struct NestedScroll {
  //可滑动头部
  @BuilderParam header: () => any
  //滑动后悬停头部
  @BuilderParam stickyHeader?: () => any
  @BuilderParam content: () => any

  //折叠进度 0～1 ，1为完全折叠
  @Link collapseProgress: number

  // 0代表滚动到List顶部，1代表中间值，2代表滚动到List底部。
  @State listPosition: number = 0
  // 0代表滚动到scroll顶部，1代表中间值，2代表滚动到List底部。
  @State scrollPosition: number = 0

  scrollerForScroll: Scroller
  scrollerForList: Scroller

  build() {
    Scroll(this.scrollerForScroll) {
      Column() {
        this.header()
        Text("Scroll Area")
          .width("100%")
          .height("40%")
          .backgroundColor(0X330000FF)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.scrollerForList.scrollToIndex(5)
          })

        // List({ space: 20, scroller: this.scrollerForList }) {
        //   ForEach(this.arr, (item) => {
        //     ListItem() {
        //       Text("ListItem" + item)
        //         .width("100%")
        //         .height("100%")
        //         .borderRadius(15)
        //         .fontSize(16)
        //         .textAlign(TextAlign.Center)
        //         .backgroundColor(Color.White)
        //     }.width("100%").height(100)
        //   }, item => item)
        // }
        // .width("100%")
        this.content()
          .height("90%")
          .edgeEffect(EdgeEffect.None)
          .onReachStart(() => {
            this.listPosition = 0
          })
          .onReachEnd(() => {
            this.listPosition = 2
          })
          .onScroll((xOffset: number, yOffset: number) => {
            console.info(xOffset + ' ' + yOffset)
          })
          .onScrollFrameBegin((offset: number) => {
            //向上 offset 为正 ，向下 为负
            console.log('onScrollFrameBegin,offset:', offset, 'listPosition', this.listPosition, 'scrollPosition', this.scrollPosition
              , 'currentOffset', this.scrollerForList.currentOffset().yOffset)
            // 子不需要滚动，只需要父滚动的情况
            if (offset <= 0) {
              //下拉时，如果子在顶部，父不在顶部，控制父滑动，直到父到顶部为止
              // if (this.scrollPosition != 0 ) {
              //防止值为0.00003
              if (Math.round(this.scrollerForList.currentOffset().yOffset) == 0) {
                //子在顶部，直接滑动父
                this.scrollPosition = 1
                this.scrollerForScroll.scrollBy(0, offset)
                console.log('滚动父容器', offset)
                return { offsetRemain: 0 }
              } else {
                //否则先滑动子
                return { offsetRemain: offset }

              }


              // }
            } else {
              //上滑时，如果父不在底部，滑动父,直到父到底部
              if (this.scrollPosition != 2) {
                this.scrollPosition = 1
                this.scrollerForScroll.scrollBy(0, offset)
                return { offsetRemain: 0 }
              }
            }
            this.listPosition = 1
            return { offsetRemain: offset };
          })

      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((side) => {
      this.scrollPosition = side
      console.log('parent onScrollEdge', side)
    })
    .onScroll((x, y) => {
      console.log('parent onScroll', x, y)
    })
    // .onScrollFrameBegin((offset: number, state: ScrollState) => {
    //   //控制父在滑动时 保证子一直在顶部
    //   this.scrollPosition = 1
    //   this.scrollerForList.scrollEdge(Edge.Top)
    //   // this.listPosition = 0
    //   console.log('parent onScrollFrameBegin offset', offset, 'scrollPosition', this.scrollPosition)
    //   return { offsetRemain: offset };
    // })

    .width("100%")
    .height("100%")
  }
}

@Entry
@Component
struct NestScrollExample {
  private scrollerForList: Scroller = new Scroller()
  private arr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  @State progress: number = 0

  @Builder header() {
      Text("这是Header").width('100%').height('100%').backgroundColor(Color.Orange)
  }

  @Builder content() {
      List({ space: 20, scroller: this.scrollerForList }) {
      ForEach(this.arr, (item) => {
        ListItem() {
          Text("ListItem" + item)
            .width("100%")
            .height("100%")
            .borderRadius(15)
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .backgroundColor(Color.White)
        }.width("100%").height(100)
      }, item => item)
    }
    .width("100%")
  }

  build() {
    Column() {
      NestedScroll({ header: this.header, content: this.content, collapseProgress: $progress })
    }
  }
}