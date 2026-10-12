package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.XMASInnovationManager;
   import Widgets.Frames.XMASInnovationGiftFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class XMASInnovationGiftWindow extends FarmWindow
   {
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BACK_MC:String = "back_mc";
      
      private const COUNT1_TF:String = "count1_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const COLLECTION_MC:Array = ["collection0_mc","collection1_mc","collection2_mc"];
      
      private const TEXT_TITLE:String = "_ChristmasUIWindow_Title";
      
      private const TEXT_BODY:String = "_ChristmasUIWindow_Body";
      
      private const TEXT_BODY2:String = "_ChristmasUIWindow_Body2";
      
      private var m_plots:XMASInnovationGiftFrame;
      
      private var m_featureName:String = null;
      
      private var m_mainWindow:XMASInnovationWindow;
      
      private var m_endDate:String;
      
      private var m_xmasInnovationManager:XMASInnovationManager;
      
      private var m_timer:Timer;
      
      public function XMASInnovationGiftWindow(featureName:String, endDate:String = "", assetPath:String = "", mainWindow:XMASInnovationWindow = null)
      {
         this.m_featureName = featureName;
         this.m_endDate = endDate;
         this.m_mainWindow = mainWindow;
         super(assetPath,true,true);
         this.m_xmasInnovationManager = XMASInnovationManager.getInstance();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.populateConsumables();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE);
         }
         if(m_window.hasOwnProperty(this.BACK_MC))
         {
            m_window[this.BACK_MC].visible = true;
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            if(this.m_xmasInnovationManager.getTimeRemainingForRedeemUnlock() > 0)
            {
               m_window[this.BODY_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY,{"days":this.getTimeLeftToUnlock()});
            }
            else
            {
               m_window[this.BODY_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY2);
            }
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_plots = new XMASInnovationGiftFrame(m_window[this.SLOTS_MC],this.m_featureName);
            this.m_plots.visible = true;
            addWidget(this.m_plots,true);
         }
      }
      
      override public function refreshWindow() : void
      {
         var featureOptInvObject:FeatureOptionsInventoryManager = FeatureOptionsInventoryManager.getInstance();
         for(var i:int = 0; i < this.COLLECTION_MC.length; i++)
         {
            if(m_window.hasOwnProperty(this.COLLECTION_MC[i]))
            {
               m_window[this.COLLECTION_MC[i]][this.COUNT1_TF].text = "x" + featureOptInvObject.getCount(this.m_xmasInnovationManager.ConsumableList[i]);
            }
         }
      }
      
      private function populateConsumables() : void
      {
         var consumableItem:FarmItem = null;
         var consumableIcon:FarmIcon = null;
         var featureOptInvObject:FeatureOptionsInventoryManager = FeatureOptionsInventoryManager.getInstance();
         var consumableList:Array = this.m_xmasInnovationManager.ConsumableList;
         for(var i:int = 0; i < this.COLLECTION_MC.length; i++)
         {
            if(m_window.hasOwnProperty(this.COLLECTION_MC[i]))
            {
               consumableItem = Global.farmGameSettingsManager.getFarmItemByCode(consumableList[i]);
               m_window[this.COLLECTION_MC[i]].visible = true;
               m_window[this.COLLECTION_MC[i]][this.COUNT1_TF].visible = true;
               m_window[this.COLLECTION_MC[i]][this.COUNT1_TF].text = "x" + featureOptInvObject.getCount(this.m_xmasInnovationManager.ConsumableList[i]);
               consumableIcon = new FarmIcon(m_window[this.COLLECTION_MC[i]]);
               consumableIcon.attachTooltip(new FarmTextTooltip(consumableItem.friendlyTitle));
            }
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         var timeLeft:String = null;
         if(m_window.hasOwnProperty(this.BODY_TF) && this.m_endDate != "")
         {
            timeLeft = this.getTimeLeftToUnlock();
            if(timeLeft == "-1")
            {
               this.m_timer.stop();
               ZLocUtils.setText(m_window,this.BODY_TF,ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY2);
               this.m_plots.refresh();
            }
            else
            {
               ZLocUtils.setText(m_window,this.BODY_TF,ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BODY,{"days":timeLeft});
            }
         }
      }
      
      public function getTimeLeftToUnlock() : String
      {
         var result:String = "";
         var timeRemaining:Number = this.m_xmasInnovationManager.getTimeRemainingForRedeemUnlock();
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(numDays > 1)
         {
            result = numDays + " days";
         }
         else
         {
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(TIMER_DELAY_MS);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer.start();
            }
            result = HUD.getformattedTimeLeft(timeRemaining);
            if(timeRemaining < 0)
            {
               result = "-1";
            }
         }
         return result;
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
      }
   }
}

