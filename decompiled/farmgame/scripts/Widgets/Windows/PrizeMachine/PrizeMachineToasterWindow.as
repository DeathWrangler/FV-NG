package Widgets.Windows.PrizeMachine
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.Event;
   
   public class PrizeMachineToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_BannerAd_prizeMachine.swf";
      
      public function PrizeMachineToasterWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         var timeLeft:Number = NaN;
         var dateArray:Array = null;
         super.postLoadComplete();
         FarmStatsManager.count(PrizeMachineWindow.STAT_COUNTER,"surface_toaster","view");
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","PrizeMachine_ToasterTitle")));
         addWidget(new ZwButton(m_window.hitbox_mc,this.onKeepPlaying));
         var message:String = "";
         if(PrizeMachineWindow.isTimedVariant())
         {
            timeLeft = PrizeMachineWindow.getTimeLeft();
            if(timeLeft != -1)
            {
               dateArray = FarmGameUtil.parseTimeLeft(timeLeft);
               message = ZLocUtils.t("Dialogs","PrizeMachine_ToasterBody_timed",{"daysLeft":(dateArray[0] != null ? dateArray[0] : 0)});
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PrizeMachine_ToasterBody_untimed");
            }
         }
         else
         {
            message = ZLocUtils.t("Dialogs","PrizeMachine_ToasterBody_untimed");
         }
         addWidget(new ZwTextField(m_window.message_tf,message));
      }
      
      private function onKeepPlaying(event:Event) : void
      {
         FarmStatsManager.count(PrizeMachineWindow.STAT_COUNTER,"surface_toaster","click");
         UI.displayPopup(new PrizeMachineWindow(),false,"PrizeMachineWindow",true);
      }
   }
}

