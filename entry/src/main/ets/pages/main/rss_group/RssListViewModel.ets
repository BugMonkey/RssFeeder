import ArrayList from '@ohos.util.ArrayList'
import { RssParser } from '../../../rss/RssParser'
import { RssItem, RssObject } from '../../../rssObject'

@Observed export class RssListViewModel {
  isRefreshing: boolean = false
  isEmpty: boolean = false
  isSuccess: boolean = false
  private rssObjects: RssObject[] = []
  rssList: RssItem[] = []
  private rssParser = new RssParser()

  //首次加载数据
  loadData(rssObjects: RssObject[]) {
    this.rssObjects = rssObjects
    this.isRefreshing = true
    //加载所有的rss地址
    this.rssList = Array.from(new Array(30).keys()).map(key=>{return new RssItem({title:''+key})})
    //rss item 按时间排序
    setTimeout(() => {
      this.isRefreshing = false
      this.isEmpty = this.rssList.length == 0
      this.isSuccess = false
    }, 2_000)
  }

  refresh() {
    this.isRefreshing = true
    this.isSuccess = true
    //先判断是否需要更新
     this.rssParser.parseRssFromUrls(this.rssObjects.map(e=> e.link ?? ''))
       .then(it=>this.rssList = it)
       .catch(e=> {
         console.error('refresh 失败：',e)
         this.isSuccess = false
       })
    setTimeout(() => {
      this.isRefreshing = false
      this.isEmpty = this.rssList.length == 0

    }, 2_000)
  }



}