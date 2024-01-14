
import { RssDbObject } from '../../models/RssDbModel'
import emitter from '@ohos.events.emitter';

@Observed
export class MainViewModel {
  inited: boolean = true;
  rssList: RssDbObject[] = [];
  isRefreshing: boolean = false;
  //隐藏标题栏事件
  private hideNavigationBarEvent = {eventId:1};

  observeEvent(){
    var callback = (eventData) => {
      console.info('callback');
    };
    emitter.on(this.hideNavigationBarEvent, callback);
  }

  unObserveEvent(){
    emitter.off(1)
  }


}
