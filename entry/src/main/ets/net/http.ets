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
      // 需要迭代查找item标签
      let itemTags = findElementByTag('item',[jsonObj])

      parseResult.items = itemTags.map((e) => {
        let item = new RssItem()
        item.title = findFirstTagContent('title',e)
        item.source = parseResult.title
        item.describe = findFirstTagContent('description',e)
        item.url = findFirstTagContent('link',e)
        const  dateString = findFirstTagContent('pubDate',e)
        if (dateString.length > 0) {
          item.pubDate = new Date(Date.parse(dateString))
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

  //根据tag查找元素
  function findElementByTag(tag:string,objs:Array<Object>): Array<Object>{
    let targets:Array<Object> = []
    for (const obj of objs) {
      const keys = Object.keys(obj)
      if (keys) {
        if (keys.indexOf('_name')!=-1){
          if (obj['_name']==tag) {
            //定位到tag
            targets.push(obj)
          }

        }
        if (keys.indexOf('_elements')!=-1) {
          targets.push(...findElementByTag(tag,obj['_elements']))
        }

      }
    }

    return targets
  }

  //查找第一个标签为tag的元素的内容
  function findFirstTagContent(tag,obj:Object){
    const tags = findElementByTag(tag,[obj])
    if (tags[0]) {
      return findElementContent(tags[0])
    }
    return ''
  }
  //查找元素的内容
  function findElementContent(obj:Object): string{
    //内部元素
    const tagElements = obj['_elements']
    //遍历这个tag内部的元素
    if (tagElements) {
      for (const element of tagElements) {
        if (element['_type'] == 'cdata') {
          return element['_cdata']
        }
        if (element['_type'] == 'text') {
          return element['_text']
        }
        if (element['_elements']) {
          for (const element of tagElements) {
            return findElementContent(element)
          }
        }
      }
    }

    return ''
  }
}


