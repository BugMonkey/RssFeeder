import { CommonUtil } from './utils/CommonUtil'

export class RssObject {
  public title?: string
  public logo?: string
  public group?: string
  public describe?: string
  public link?: string
  public items?: Array<RssItem>
  public id?: string = CommonUtil.getUuid()
}

export class RssItem {
  title?: string
  describe?: string
  creator?: string
  pubDate?: Date
  //原文地址
  url?: string
  //rss源
  source?: string
  //rss源logo
  sourceLogo?: string


  constructor(obj ?: { title?: string,
    describe?: string,
    creator?: string,
    pubDate?: Date,
    url?: string,
    source?: string,
    sourceLogo?: string}){
    if (obj) {
      this.title = obj.title
      this.describe = obj.describe
      this.creator = obj.creator
      this.pubDate = obj.pubDate
      this.url = obj.url
      this.source = obj.source
      this.sourceLogo = obj.sourceLogo
    }

  }
}