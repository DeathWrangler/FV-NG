package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Dec19InnovationManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   
   public class Dec19InnovationBuyWindow extends FeaturePackagesBuyWindow
   {
      
      private var m_bucketPackages:Array;
      
      private const ASK_BT:String = "ask_bt";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_tileUnlock_bt:FarmAnimatedTextButton;
      
      private var m_unlock_tf:ZwTextField;
      
      private var m_mainWindow:Dec19InnovationMainWindow;
      
      private var m_IconMc:FarmIcon;
      
      private var m_owner:FarmWindow;
      
      public function Dec19InnovationBuyWindow(dialogPath:String, featureName:String, itemPackages:Array, owner:FarmWindow = null, mainWindow:Dec19InnovationMainWindow = null)
      {
         m_featureName = featureName;
         this.m_owner = owner;
         this.m_bucketPackages = itemPackages;
         this.m_mainWindow = mainWindow;
         super(dialogPath,m_featureName,this.m_bucketPackages,this.m_owner);
      }
      
      override protected function postLoadComplete() : void
      {
         var consumbaleItem:FarmItem = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.ASK_BT))
         {
            addWidget(this.m_ask_bt = new FarmAnimatedTextButton(m_window[this.ASK_BT],"Ask",this.onAskButtonClick));
         }
         if(m_window.hasOwnProperty(this.CRAFT_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.CRAFT_BT],"Craft",this.m_mainWindow.onCraftButtonClick));
         }
         addWidget(this.m_tileUnlock_bt = new FarmAnimatedTextButton(m_window["unlock_bt"],"Unlock Land",this.m_mainWindow.openMiniMarket));
         if(this.manager.lockedTilesArray.length > 0)
         {
            this.m_unlock_tf = new ZwTextField(m_window["unlock_tf"],"Get 50 Gift Ribbons free with every tile unlock");
            this.m_unlock_tf.visible = true;
         }
         else
         {
            this.m_tileUnlock_bt.enabled = false;
            this.m_tileUnlock_bt.callback = null;
            this.m_tileUnlock_bt.applyGrayOut = true;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_tileUnlock_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_MainWindow_UnlockTileText2"));
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            this.m_IconMc = new FarmIcon(m_window["icon_mc"]);
            consumbaleItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.ConsumableCode);
            if(this.m_IconMc)
            {
               this.m_IconMc.loadIcon(consumbaleItem.iconUrl);
               this.m_IconMc.visible = true;
            }
         }
         if(this.m_ask_bt)
         {
            this.refreshAskButton();
         }
      }
      
      public function onAskButtonClick(event:Event) : void
      {
         if(this.m_ask_bt.enabled)
         {
            this.m_ask_bt.enabled = false;
            this.manager.askForConsumables();
            FarmStatsManager.count("Ask","Gift Ribbons");
            this.refreshAskButton();
         }
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_ask_bt)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(Dec19InnovationManager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_ask_bt,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_ask_bt.enabled = true;
               this.m_ask_bt.detachTooltip();
            }
         }
      }
      
      private function get manager() : Dec19InnovationManager
      {
         return Dec19InnovationManager.getInstance(m_featureName);
      }
      
      override public function close() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
         super.close();
      }
   }
}

