export class RssObject{
  public title?:string
  public logo?:string
  public describe?:string
  public link?:string
  public items?:Array<RssItem>
}

export class RssItem{
  title?:string
  describe?:string
  creator?:string
  pubDate?:Date
  //原文地址
  url?:string
  //rss源
  source?:string
  //rss源logo
  sourceLogo?:string

}