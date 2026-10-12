package Widgets.Windows.MOTD
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Managers.UnlimitedPacksManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class UnlimitedPacksMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private var m_timer:Timer;
      
      private var m_timerTextField:ZwTextField;
      
      private var m_timerFrame:ZwFrame;
      
      private var m_featureName:String = UnlimitedPacksManager.FEATURE_NAME;
      
      private var m_bundleItem:FarmItem;
      
      private var m_featureManager:UnlimitedPacksManager = UnlimitedPacksManager.getInstance();
      
      private var m_endDate:String = this.m_featureManager.FEATURE_END_DATE;
      
      private var m_bundleBuyButton:FarmAnimatedCashButton;
      
      public function UnlimitedPacksMOTDWindow(displayParams:Object = null)
      {
         this.m_bundleItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_featureManager.BUNDLE_ITEM_NAME);
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleText:String = null;
         var bodyText:String = null;
         addWidget(new ZwBaseWidget(m_window.mainWindow));
         if(m_window.mainWindow.title_tf)
         {
            titleText = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_MOTD_title");
            if(titleText != "")
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,titleText));
            }
         }
         if(m_window.mainWindow.body_tf)
         {
            bodyText = ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_MOTD_body");
            if(bodyText != "")
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,bodyText));
            }
         }
         if(m_window.mainWindow.hasOwnProperty("close_bt"))
         {
            m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
         }
         if(m_window.mainWindow.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_bundleBuyButton = new FarmAnimatedCashButton(m_window.mainWindow.accept_bt,"",this.m_bundleItem.cash.toString(),onAcceptCashButton));
            addWidget(new ZwTextField(m_window.mainWindow.accept_bt.generic_tf,ZLocUtils.t(ZLOC_PACKAGE_DIALOGS,this.m_featureName + "_ActionButton_Text")));
            this.m_bundleBuyButton.showPaymentConfirmation = true;
         }
         if(m_window.mainWindow.hasOwnProperty("bonus_mc"))
         {
            addWidget(this.m_timerFrame = new ZwFrame(m_window.mainWindow.bonus_mc));
            if(this.m_timerFrame)
            {
               if(m_window.mainWindow.bonus_mc.hasOwnProperty("mimted_tf"))
               {
                  this.m_timerFrame.addWidget(this.m_timerTextField = new ZwTextField(m_window.mainWindow.bonus_mc.mimted_tf,this.getExpiryDateText())) as ZwTextField;
               }
               if(m_window.mainWindow.bonus_mc.hasOwnProperty("valuebanner_mc"))
               {
                  this.m_timerFrame.addWidget(new ZwFrame(m_window.mainWindow.bonus_mc.valuebanner_mc)) as ZwFrame;
               }
            }
         }
      }
      
      private function getExpiryDateText() : String
      {
         var result:String = "";
         var timeRemaining:Number = (FarmGameUtil.synchronizedDateToNumber(this.m_endDate) - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         var numDays:int = Math.ceil(timeRemaining / FarmGameUtil.NUM_SECS_IN_DAY);
         if(numDays > 1)
         {
            result = ZLocUtils.t("Dialogs","Harvest_Helper_Hud_text",{"days":numDays});
         }
         else
         {
            if(this.m_timer == null)
            {
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
               this.m_timer.start();
            }
            result = HUD.getformattedTimeLeft(timeRemaining);
         }
         return result;
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(this.m_timerTextField)
         {
            this.m_timerTextField.text = this.getExpiryDateText();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.onClose(event);
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

