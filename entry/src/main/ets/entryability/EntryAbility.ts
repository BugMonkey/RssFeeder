import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';


export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    let context = this.context;

    //数据库初始
    // const kvManagerConfig = {
    //   context:context,
    //   bundleName:'com.cheercola.rssfeeder'
    // };
    // try {
    //   kvManager = distributedKVStore.createKVManager(kvManagerConfig)
    //   console.error('创建kvmanager成功')
    // }catch (e){
    //   console.error('创建kvmanager失败')
    // }
    //  模拟器上不能用
    // PersistentStorage.PersistProp('aProp', 47);
  }

  async enterImmersion(windowClass: window.Window) {
    // 获取状态栏和导航栏的高度
    windowClass.on("avoidAreaChange", ({ type, area }) => {
      if (type == window.AvoidAreaType.TYPE_SYSTEM) {
        // 将状态栏和导航栏的高度保存在AppStorage中
        AppStorage.SetOrCreate<number>("topHeight", area.topRect.height);
        AppStorage.SetOrCreate<number>("bottomHeight", area.bottomRect.height);
      }
    })
    // 设置窗口布局为沉浸式布局
    // await windowClass.setWindowLayoutFullScreen(true)
    // await windowClass.setWindowSystemBarEnable(["status", "navigation"])
    // 设置状态栏和导航栏的背景为透明
    await windowClass.setWindowSystemBarProperties({
      navigationBarColor: "#00000000",
      statusBarColor: "#00000000",
      navigationBarContentColor: "#FF0000",
      statusBarContentColor: "#FF0000"
    })
  }


  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

   onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((windowClass)=>{
       this.enterImmersion(windowClass);
    })

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
