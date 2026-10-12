package Display
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class CoconutSurfaceReminder extends Dialog
   {
      
      private static const COCONUT_REMINDER:String = "coconut_reminder";
      
      public function CoconutSurfaceReminder()
      {
         m_dialogAsset = "assets/dialogs/FV_coconutSurface.swf";
         super(true);
      }
      
      public static function conditionallyShowCoconutReminder() : void
      {
         if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HAWAII)
         {
            if(!Global.player.getSeenFlag(COCONUT_REMINDER) && Global.player.totalCashPurchased > 0)
            {
               UI.displayPopup(new CoconutSurfaceReminder(),false,"coconut_reminder",true);
            }
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClickClose);
         var okayButton:GenericButton = new GenericButton(m_window.okay_bt,this.onClickOk);
         okayButton.text = ZLocUtils.t("Dialogs","ShowMe");
         FarmStatsManager.count("dialog","onetime_coconut_remind","view");
      }
      
      private function onClickClose(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog","onetime_coconut_remind","X");
         this.onClose(event);
      }
      
      private function onClickOk(event:MouseEvent) : void
      {
         UI.displayMarketDialog(null,"aide",null,"other",null,"currency_exchange");
         FarmStatsManager.count("dialog","onetime_coconut_remind","OK");
         this.onClose(event);
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         Global.player.setSeenFlag(COCONUT_REMINDER);
         m_window.okay_bt.removeEventListener(MouseEvent.CLICK,this.onClickOk);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClickClose);
         event.stopPropagation();
         close();
      }
   }
}

