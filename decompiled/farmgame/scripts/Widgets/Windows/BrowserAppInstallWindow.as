package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class BrowserAppInstallWindow extends FarmWindow
   {
      
      public static var m_displayIndex:int = 0;
      
      public static const FEATURE_OPTIONS_KEY:String = "BROWSER_APP";
      
      public static const COOL_DOWN_TIME:Array = [86400,172800,2592000];
      
      public static const DISPLAY_LIMIT:Array = [3,15];
      
      public static const FV_BROWSER_INSTALL_LAST_SHOWN_KEY:String = "browser_app_last_shown";
      
      public static const FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY:String = "browser_app_window_pop_count";
      
      private static const SERVICE_NAME:String = "BrowserAppInstall2019Service";
      
      private static const ZRUNTIME_BROWSER_INSTALL_DISPLAY_LIMIT_MAX:String = "BROWSER_INSTALL_DISPLAY_LIMIT_MAX";
      
      private static const ZRUNTIME_BROWSER_INSTALL_COOL_TIME_MAX:String = "BROWSER_INSTALL_COOL_TIME_MAX";
      
      private static const ZRUNTIME_BROWSER_INSTALL_DISPLAY_LIMIT_ARRAY:String = "BROWSER_INSTALL_DISPLAY_LIMIT_ARRAY";
      
      private static const ZRUNTIME_BROWSER_INSTALL_COOL_TIME_ARRAY:String = "BROWSER_INSTALL_COOL_TIME_ARRAY";
      
      public var m_URL:String;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_close_bt:*;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function BrowserAppInstallWindow(assetPath:String = "", url:String = null)
      {
         super(assetPath);
         this.m_URL = url;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titleTf = new ZwTextField(m_window["title_tf"],"New Way to Play!"));
            this.m_titleTf.visible = true;
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(this.m_bodyTf = new ZwTextField(m_window["body_tf"],"Download and Install our new browser built to seamlessly play Farmville!"));
            this.m_bodyTf.visible = true;
         }
         if(m_window.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = m_window["close_bt"];
            this.m_close_bt.addEventListener(MouseEvent.CLICK,this.onCloseBrowserInstallWindow);
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Download Now!",this.onAccept));
            this.m_accept_bt.enabled = true;
         }
         StatsManager.count("MOTD","impressions","FarmvilleAppMOTDWindow");
      }
      
      public function getCount(key:String) : int
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY);
         if(!featureData)
         {
            featureData = new Object();
            featureData[FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY] = 0;
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY,featureData);
         }
         return int(featureData[FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY]);
      }
      
      private function setCount(key:String, count:int) : void
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY);
         if(!featureData)
         {
            featureData = new Object();
         }
         featureData[FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY] = count;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_OPTIONS_KEY,FEATURE_OPTIONS_KEY,featureData);
      }
      
      private function onAccept(vt:MouseEvent) : void
      {
         navigateToURL(new URLRequest(this.m_URL),"_blank");
         StatsManager.count("MOTD","click","FarmvilleAppMOTDWindow");
      }
      
      private function onCloseBrowserInstallWindow(evt:MouseEvent) : void
      {
         var FVBrowserInstall_ViewCount:Number = this.getCount(FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY) + 1;
         this.setCount(FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY,FVBrowserInstall_ViewCount);
         Global.player.setFeatureLastShown(FV_BROWSER_INSTALL_LAST_SHOWN_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"closeBrowserInstallWindow",null));
         StatsManager.count("MOTD","close","FarmvilleAppMOTDWindow");
         super.onClose(evt);
      }
      
      private function getDisplayLimitArray() : Array
      {
         var displayLimitArray:Array = new Array();
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_BROWSER_INSTALL_DISPLAY_LIMIT_ARRAY))
         {
            displayLimitArray = Global.flashHotParams[ZRUNTIME_BROWSER_INSTALL_DISPLAY_LIMIT_ARRAY].split(",");
         }
         return displayLimitArray;
      }
      
      private function getCoolDownTimeArray() : Array
      {
         var coolDownTimeArray:Array = new Array();
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_BROWSER_INSTALL_COOL_TIME_ARRAY))
         {
            coolDownTimeArray = Global.flashHotParams[ZRUNTIME_BROWSER_INSTALL_COOL_TIME_ARRAY].split(",");
         }
         return coolDownTimeArray;
      }
      
      public function canShowAppInstallWindow() : Boolean
      {
         var key:String = FV_BROWSER_INSTALL_LAST_SHOWN_KEY;
         var timeSinceLastPopup:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var FVBrowserInstall_ViewCount:Number = this.getCount(FV_BROWSER_INSTALL_FEATURESHOWN_COUNT_KEY);
         var coolDownTimeArray:Array = this.getCoolDownTimeArray();
         var displayLimitArray:Array = this.getDisplayLimitArray();
         if(m_displayIndex < Global.flashHotParams[ZRUNTIME_BROWSER_INSTALL_DISPLAY_LIMIT_MAX])
         {
            if(FVBrowserInstall_ViewCount >= displayLimitArray[m_displayIndex])
            {
               ++m_displayIndex;
            }
         }
         var timeRemaining:int = coolDownTimeArray[m_displayIndex] - timeSinceLastPopup;
         return timeRemaining < 0;
      }
   }
}

