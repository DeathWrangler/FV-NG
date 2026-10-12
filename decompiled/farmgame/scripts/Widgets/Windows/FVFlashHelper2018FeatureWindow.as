package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class FVFlashHelper2018FeatureWindow extends FarmWindow
   {
      
      public static const FEATURE_OPTIONS_KEY:String = "FLASH_PLUGIN";
      
      public static const FLASHPLUGIN_REWARDGRANTED_FLAG:String = "FVPlugin_RewardGranted";
      
      public static const COOL_DOWN_TIME:int = 172800;
      
      public static const REWARD_FC:* = 10;
      
      public static const DISPLAY_LIMIT:int = 5;
      
      public static const FV_FLASHHELPER_LAST_SHOWN_KEY:String = "flash_plugin_feature_last_shown";
      
      private static const API_CHECK_FVPLUGIN:String = "FarmNS.CheckChromePlugin";
      
      private static const SERVICE_NAME:String = "FVFlashHelper2018Service";
      
      public static const FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY:String = "flash_plugin_feature_pop_count";
      
      private var m_titletf:ZwTextField;
      
      private var m_bodytf:ZwTextField;
      
      private var m_body2tf:ZwTextField;
      
      private var m_close_bt:*;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_faq_bt:FarmAnimatedTextButton;
      
      public function FVFlashHelper2018FeatureWindow(dialogPath:String = "assets/dialogs/ChromePlugin2018/FV_motd_ChromePlugin2018.swf")
      {
         super(dialogPath);
      }
      
      public function onCheckChromePluginResponse(result:Object = null, isPluginInstalled:Boolean = false) : void
      {
         if(!isPluginInstalled && this.canPopwindow() && this.getCount(FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY) < DISPLAY_LIMIT)
         {
            UI.displayPopup(new FVFlashHelper2018FeatureWindow("assets/dialogs/ChromePlugin2018/FV_motd_ChromePlugin2018.swf"),false);
            StatsManager.count("chrome_extension","impresssions","feature_window",this.getCount(FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY).toString());
         }
         if(isPluginInstalled)
         {
            if(Global.hud)
            {
               Global.hud.removeBottomHudFvPlugin();
            }
            if(!Global.player.getSeenFlag(FLASHPLUGIN_REWARDGRANTED_FLAG))
            {
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantReward",this.onGrantReward));
            }
            else
            {
               StatsManager.count("chrome_extension","reinstall");
            }
         }
      }
      
      public function launchFlashPluginFeature() : void
      {
         var result:Object = {};
         ExternalUtil.instance.addCallback("onCheckChromePluginResponse",ZCacheUtil.applyPartial(this.onCheckChromePluginResponse,this,[result]));
         ExternalUtil.instance.call(API_CHECK_FVPLUGIN);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titletf = new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_Title")));
            this.m_titletf.visible = true;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodytf = new ZwTextField(m_window["body_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_text")));
            this.m_bodytf.visible = true;
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            addWidget(this.m_body2tf = new ZwTextField(m_window["body2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_CHROMEPLUGIN2018_subtext")));
            this.m_body2tf.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = m_window["close_bt"];
            this.m_close_bt.addEventListener(MouseEvent.CLICK,this.onCloseFlashHelperFeatureWindow);
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Get It now!",this.onAccept));
            this.m_accept_bt.enabled = true;
         }
         if(m_window.hasOwnProperty("faq_bt"))
         {
            addWidget(this.m_faq_bt = new FarmAnimatedTextButton(m_window["faq_bt"],"Know More",this.onKnowMore));
            this.m_faq_bt.enabled = true;
         }
      }
      
      private function onCloseFlashHelperFeatureWindow(evt:MouseEvent) : void
      {
         var FVPlugin_ViewCount:Number = this.getCount(FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY) + 1;
         this.setCount(FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY,FVPlugin_ViewCount);
         StatsManager.count("chrome_plugin","CloseUI",FVPlugin_ViewCount.toString());
         Global.player.setFeatureLastShown(FV_FLASHHELPER_LAST_SHOWN_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"closeWindow",null));
      }
      
      private function getCount(key:String) : int
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY);
         if(!featureData)
         {
            featureData = new Object();
            featureData[FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY,featureData);
         }
         return int(featureData[FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY]);
      }
      
      private function setCount(key:String, count:int) : void
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY);
         if(!featureData)
         {
            featureData = new Object();
         }
         featureData[FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY] = count;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY,featureData);
      }
      
      private function onAccept(vt:MouseEvent) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","FLASHPLUGIN_CHROME_URL")),"_blank");
         FarmStatsManager.count("MOTD","get_it_now","chrome_extension");
      }
      
      private function onKnowMore(evt:MouseEvent) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","FLASHPLUGIN_KNOW_MORE_FAQ_URL")),"_blank");
         FarmStatsManager.count("MOTD","know_more","chrome_extension");
      }
      
      public function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(FLASHPLUGIN_REWARDGRANTED_FLAG);
            Global.player.addGift("pegasus_royalegold","0",1);
            Global.player.addGift("pegasus_heartking","0",1);
            Global.player.cash += REWARD_FC;
            FVFlashHelper2018RewardWindow.launchPluginRewardWindow();
            StatsManager.count("chrome_extension","impresssions","reward_window",this.getCount(FV_FLASHHELPER_FEATURESHOWN_COUNT_KEY).toString());
         }
      }
      
      private function canPopwindow() : Boolean
      {
         var key:String = FV_FLASHHELPER_LAST_SHOWN_KEY;
         var timeSinceLastPopup:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = COOL_DOWN_TIME - timeSinceLastPopup;
         return timeRemaining < 0;
      }
   }
}

