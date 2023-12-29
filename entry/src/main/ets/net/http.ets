import http from '@ohos.net.http';

export class Response {
  code: number
  msg: string | Resource
  data: any
}

export class RssXmlResult {
  result: string
  isSuccess: boolean

  constructor(result: string, isSuccess: boolean) {
    this.result = result
    this.isSuccess = isSuccess
  }
}

///请求rss
export async function rssRequest(url: string): Promise<RssXmlResult> {
  try {
    let response = await  http.createHttp()
      .request(url, { method: http.RequestMethod.GET, usingCache: true, connectTimeout: 15_000 });
    if (response.responseCode === http.ResponseCode.OK) {
      let xml = response.result.toString()
      return new RssXmlResult(xml, true);
    } else {
      console.error(response.result.toString())
      new RssXmlResult(response.responseCode.toString(), false)
    }
  } catch (e) {
    console.error(e)
    new RssXmlResult(e.toString, false)
  }


}


