//请求rss地址并解析结果
import taskpool from '@ohos.taskpool';
import { rssRequest } from '../net/http';
import { RssItem } from '../rssObject';
import common from '@ohos.app.ability.common';

export class RssParser {
  async parseRssFromUrls(urls: string[]) {
    let items: RssItem[] = []
    // for (const url of urls) {
      // let task: taskpool.Task = new taskpool.Task(this.parseRssUrl)
      // let taskResult = await taskpool.execute(task)
      // items.push(...taskResult)
    // }
    let result = await Promise.all(urls.map(url => this.parseRssUrl(url)))
    items = result.flat()
    //排序
    items.sort((a, b) => {
      return (a.pubDate?.getTime() ?? 0) - (b.pubDate?.getTime() ?? 0)
    })
    return items
  }


  // @Concurrent 无效
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

