package Classes.MOTD
{
   public class SubscriptionsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_Subscriptions_MOTD.swf";
      
      public function SubscriptionsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
      }
   }
}

