package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public class CPAFlowerOfferMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_Promo_ProFlowers.swf";
      
      public function CPAFlowerOfferMOTDWindow()
      {
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonText:String = ZLocUtils.t("Dialogs","MOTD_CPAFlowerOfferButtonText");
         super.postLoadComplete();
         if(m_window.okay_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,buttonText,this.onTrialPayTrigger));
         }
         FarmStatsManager.count("Flowers_CPAoffer","MOTD","view");
      }
      
      private function onTrialPayTrigger(event:MouseEvent) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("triggerTrialPlayClick");
         }
         FarmStatsManager.count("Flowers_CPAoffer","MOTD","click_earn");
         super.onClose(event);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("Flowers_CPAoffer","MOTD","x_cancel");
         super.onClose(event);
      }
   }
}

