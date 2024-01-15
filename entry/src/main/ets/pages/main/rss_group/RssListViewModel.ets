import { RssParser } from '../../../rss/RssParser'
import { RssObject } from '../../../rssObject'
import { CommonDataSource } from '../../../utils/CommonDataSource'

@Observed export class RssListViewModel {
  isRefreshing: boolean = false
  isEmpty: boolean = false
  isSuccess: boolean = false
  private rssObjects: RssObject[] = []
  // rssList: RssItem[] = []
  private rssParser = new RssParser()
  dataSource = new CommonDataSource([])

  //加载数据
  refresh(objArray: RssObject[]): void {
    if (objArray == this.rssObjects) {
      this.isRefreshing = false
      return
    }

    if (objArray.length == 0) {
      this.isEmpty = true
      this.isRefreshing = false
      return
    }
    //先判断是否需要更新
    this.rssParser.parseRssFromUrls(objArray.map(e => e.link ?? ''))
      .then(it => {
        this.dataSource.setData(it)
        this.isSuccess = true
        this.rssObjects = objArray
      }
      )
      .catch(e => {
        console.error('refresh 失败：', e)
        this.isSuccess = false
      })
      .finally(() => {
        setTimeout(() => {
          this.isRefreshing = false
          this.isEmpty = this.dataSource.totalCount() == 0

        }, 500)
      })

  }
}