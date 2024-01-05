import distributedKVStore from '@ohos.data.distributedKVStore';
import { kvManager } from '../../entryability/EntryAbility';
import { RssDbModel } from '../../models/RssDbModel'
import { DbUtil } from '../../utils/db_util';

@Observed
export class MainViewModel{
   inited: boolean = false;
   rssList: Array<RssDbModel> = [new RssDbModel(1, '1', 'link', 'logo', 'describe'), new RssDbModel(2, '2', 'link', 'logo', 'describe'),];
   isRefreshing: boolean = false;

   loadData(){
      // this.rssList = []
      DbUtil.queryAllRssData(getContext(this)).then((result) => {
         this.rssList = result
      }).finally(() => {
         setTimeout(() => {
            this.inited = true
            this.isRefreshing = false
         }, 1_000)
      })

      const options = {
         createIfMissing: true, // 当数据库文件不存在时是否创建数据库，默认创建
         encrypt: false, // 设置数据库文件是否加密，默认不加密
         backup: false, // 设置数据库文件是否备份，默认备份
         kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION, // 设置要创建的数据库类型，默认为多设备协同数据库
         securityLevel: distributedKVStore.SecurityLevel.S2 // 设置数据库安全级别
      }
      // storeId为数据库唯一标识符
      new Promise<void>((resolve) => {
         kvManager.getKVStore<distributedKVStore.SingleKVStore>('storeId', options, async (err, kvStore) => {
            if (err) {
               console.error(`Failed to get KVStore. Code:${err.code},message:${err.message}`);
               return;
            }
            console.info('Succeeded in getting KVStore.');
            // 进行相关数据操作
            let jsonData = await kvStore.get('Proceedings of the National Academy of Sciences: This Week in PNAS')

            try {
               if (jsonData instanceof String ){
                  const rssObj = JSON.parse(jsonData as string)
               }

            } catch (e) {
               console.error(e)
            }
         });
         resolve()
      })
   }
}
