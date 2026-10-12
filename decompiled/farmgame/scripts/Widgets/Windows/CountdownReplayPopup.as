package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.HolidayCountdownManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class CountdownReplayPopup extends FarmWindow
   {
      
      private const SWF_NAME:String = "assets/dialogs/FV_AroundtheWorldCountdown_replay.swf";
      
      public function CountdownReplayPopup(assetUrl:String)
      {
         if(assetUrl == "")
         {
            assetUrl = this.SWF_NAME;
         }
         super(assetUrl);
      }
      
      override protected function onShow() : void
      {
         super.onShow();
      }
      
      override protected function postLoadComplete() : void
      {
         var headline:String = null;
         var body:String = null;
         var bConfirm:String = null;
         var legal:String = null;
         super.postLoadComplete();
         var bonusItem:FarmItem = HolidayCountdownManager.getBonusItem();
         var frame:ZwFrame = addWidget(new ZwFrame(m_window.mainWindow)) as ZwFrame;
         headline = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("Replay_Title"));
         body = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,HolidayCountdownManager.getFeatureSpecificKey("Replay_Body"),{"item":bonusItem.friendlyTitle});
         bConfirm = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdown_Replay_Button_Text");
         legal = ZLocUtils.t(HolidayCountdownManager.DEFAULT_FEATURE_NAME,"HolidayCountdown_Replay_Legal",{"quantity":HolidayCountdownManager.getDaysLeftInCampaign() + HolidayCountdownManager.getNumberOfExtraDays()});
         if(headline)
         {
            addWidget(new ZwTextField(frame.element.headline_tf,headline));
         }
         if(body)
         {
            addWidget(new ZwTextField(frame.element.body_tf,body));
         }
         if(bConfirm)
         {
            addWidget(new FarmAnimatedTextButton(frame.element.connect_bt,bConfirm,this.handleConfirmClick));
         }
         if(legal)
         {
            addWidget(new ZwTextField(frame.element.legal_tf,legal));
         }
         FarmStatsManager.count(HolidayCountdownManager.getStatCounter(),HolidayCountdownManager.STAT_COMPLETED_DIALOG_SUBCOUNTER,"keep_going","ok_button","impressions");
      }
      
      private function handleConfirmClick(e:Event) : void
      {
         if(HolidayCountdownManager.canRestartCountdown())
         {
            HolidayCountdownManager.restartCountdown();
         }
         super.onClose(e);
      }
   }
}

