//请求rss地址并解析结果
import taskpool from '@ohos.taskpool';
import { rssRequest } from '../net/http';
import { RssItem } from '../rssObject';
import common from '@ohos.app.ability.common';

export class RssParser {
  // 解析所有rss链接
  async parseRssFromUrls(urls: string[]):Promise<RssItem[]> {
    let itemsArray = await Promise.all(urls.map(url => this.parseRssUrl(url)))
    let result = await this.sortRssItems(itemsArray)
    return result

  }

  // 为所有rssItem排序
  sortRssItems(result :RssItem[][]):Promise<RssItem[]>{
   return new Promise((resolve)=>{
      let items: RssItem[] = []
      // for (const url of urls) {
      // let task: taskpool.Task = new taskpool.Task(this.parseRssUrl)
      // let taskResult = await taskpool.execute(task)
      // items.push(...taskResult)
      // }

      items = result.flat()
      //排序
      items.sort((a, b) => {
        return (b.pubDate?.getTime() ?? 0) - (a.pubDate?.getTime() ?? 0)
      })
      resolve(items)
    })
  }


  // @Concurrent 无效
  //解析单个rss
  async parseRssUrl(url: string): Promise<RssItem[]> {
    if (url.length == 0) {
      return []
    }
    let rssItems: RssItem[] = []
    let result = await rssRequest(url)
    if (result.isSuccess) {
      rssItems.push(...(result.result.items || []))
    } else {
      console.error('rssRequest 失败：', result.msg)
    }
    return rssItems
  }
}

