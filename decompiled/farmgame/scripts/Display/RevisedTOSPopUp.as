package Display
{
   import Managers.FarmStatsManager;
   import flash.display.MovieClip;
   
   public class RevisedTOSPopUp extends GenericPopup
   {
      
      internal const ASSET_PATH:* = "assets/dialogs/FV_GDPR_PopUp.swf";
      
      private var m_popupBox_mc:MovieClip;
      
      public function RevisedTOSPopUp(message:String, popType:int = 0, closeCallback:Function = null, dialogAsset:* = "assets/dialogs/FV_GDPR_PopUp.swf", rewardUrl:String = "", useHtmlText:Boolean = false)
      {
         super(message,popType,closeCallback,dialogAsset,rewardUrl,useHtmlText);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         this.m_popupBox_mc = m_window.popupBox_mc;
         if(this.m_popupBox_mc.hasOwnProperty("link1_tf"))
         {
            this.m_popupBox_mc.link1_tf.htmlText = "<a href=\"https://www.zynga.com/legal/terms-of-service\" style=\'text-decoration: underline;\' target=\'_blank\' style=\"cursor: pointer;\">Terms of Service</a>";
         }
         if(this.m_popupBox_mc.hasOwnProperty("link2_tf"))
         {
            this.m_popupBox_mc.link2_tf.htmlText = "<a href=\"https://www.zynga.com/privacy/policy\" style=\'text-decoration: underline;\' target=\'_blank\' style=\"cursor: pointer;\">Privacy Policy</a>";
         }
         FarmStatsManager.count("GDPR","revisedTOS","view");
      }
   }
}

