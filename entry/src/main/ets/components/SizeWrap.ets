/**
 *
 */
@Component
export struct FixSizeWrap{
  @Link childSize: {
    width: number,
    height: number
  }
  @BuilderParam child:() => void

  build() {
    Stack(){
      this.child()
    }.onAreaChange((_, newValue) => {
      this.childSize = { width: newValue.width as number, height: newValue.height as number }
      console.log(this.childSize.width.toString())
    })
    .flexGrow(1)
  }
}