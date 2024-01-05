import http from '@ohos.net.http';
import convertxml from '@ohos.convertxml';
import { RssItem, RssObject } from '../rssObject';

export class Response {
  code: number
  msg: string | Resource
  data: any
}

export class RssXmlResult {
  result: RssObject
  isSuccess: boolean
  msg: string = ''

  constructor(isSuccess: boolean, {result,msg}: {
    result?: RssObject,
    msg?: string
  }) {
    this.result = result
    this.isSuccess = isSuccess
    this.msg = msg
  }
}

///请求rss
export async function rssRequest(url: string): Promise<RssXmlResult> {

  try {
    let response = await  http.createHttp()
      .request(url, { method: http.RequestMethod.GET, usingCache: true, connectTimeout: 15_000 });
    if (response.responseCode === http.ResponseCode.OK) {
      let xml: string | Object | ArrayBuffer = response.result
      var parseResult: RssObject = new RssObject()
      let conv = new convertxml.ConvertXML();
      let options = {
        trim: false,
        declarationKey: "_declaration",
        instructionKey: "_instruction",
        attributesKey: "_attributes",
        textKey: "_text",
        cdataKey: "_cdata",
        doctypeKey: "_doctype",
        commentKey: "_comment",
        parentKey: "_parent",
        typeKey: "_type",
        nameKey: "_name",
        elementsKey: "_elements"
      }
      let jsonObj = conv.convertToJSObject(xml.toString(), options)
      console.log(JSON.stringify(jsonObj));
      let channel = Array.from(jsonObj['_elements'][0]['_elements'][0]['_elements']);
      if (channel != null) {
        parseResult.title = channel.find((e) => e['_name'] == 'title')?.['_elements'][0]?.['_text'];
        parseResult.link = channel.find((e) => e['_name'] == 'link')?.['_elements'][0]?.['_text'];
        parseResult.describe = channel.find((e) => e['_name'] == 'description')?.['_elements'][0]?.['_text'];
      }
      let items = Array.from(jsonObj['_elements'][0]['_elements']).filter((e) => e['_name'] == 'item')
      parseResult.items = items.map((e) => {
        let item = new RssItem()
        let attrs = e['_elements']

        for (let attrsKey in attrs) {
          let attr = attrs[attrsKey]
          if (attr['_name'] == 'title') {
            item.title = attr['_elements'][0]['_text'] ?? attr['_elements'][0]['_cdata']
          }
          if (attr['_name'] == 'creator') {
            item.creator = attr['_elements'][0]['_text']
          }
          if (attr['_name'] == 'date') {
            item.pubDate = new Date(Date.parse(attr['_elements'][0]['_text']))
          }
          item.source = parseResult.title
          item.sourceLogo = parseResult.logo
          if (attr['_name'] == 'link') {
            item.url = attr['_elements'][0]['_text']
          }
        }
        return item
      })

      return new RssXmlResult(true, { result: parseResult });
    } else {
      console.error(response.result.toString())
      return new RssXmlResult(false, { msg: response.result.toString() })
    }
  } catch (e) {
    console.error(e['message'] )
    return new RssXmlResult(false, { msg: e['message'] })
  }


}


