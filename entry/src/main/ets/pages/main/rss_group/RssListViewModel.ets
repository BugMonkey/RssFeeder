import ArrayList from '@ohos.util.ArrayList'
import { RssParser } from '../../../rss/RssParser'
import { RssItem, RssObject } from '../../../rssObject'

@Observed export class RssListViewModel {
  isRefreshing: boolean = false
  isEmpty: boolean = false
  isSuccess: boolean = false
  private rssObjects: RssObject[]
  rssList: RssItem[] = []
  private rssParser = new RssParser()

  //加载数据
  refresh(objArray?: RssObject[]) {
    if (objArray) {
      this.rssObjects = objArray
    }

    this.isRefreshing = true
    //先判断是否需要更新
    this.rssParser.parseRssFromUrls(this.rssObjects.map(e => e.link ?? ''))
      .then(it => {
        this.rssList = it
        this.isSuccess = true
      }
      )
      .catch(e => {
        console.error('refresh 失败：', e)
        this.isSuccess = false
      })
    setTimeout(() => {
      this.isRefreshing = false
      this.isEmpty = this.rssList.length == 0

    }, 2_000)
  }
}