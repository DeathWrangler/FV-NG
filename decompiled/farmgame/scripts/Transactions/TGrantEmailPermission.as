package Transactions
{
   public class TGrantEmailPermission extends TFarmTransaction
   {
      
      private var m_permissionSource:String = null;
      
      public function TGrantEmailPermission(permissionSource:String = null)
      {
         super();
         if(permissionSource != null)
         {
            this.m_permissionSource = permissionSource;
         }
      }
      
      override public function perform() : void
      {
         if(this.m_permissionSource != null)
         {
            signedCall("ZAPIClientService.grantEmailPermissionWithGift",this.m_permissionSource);
         }
         else
         {
            signedCall("ZAPIClientService.grantEmailPermission");
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result != null && result.receivedEmailGift) && Boolean(result.receivedEmailGift == "true") && Boolean(result.giftName))
         {
            Global.player.addGift(result.giftName);
            Global.player.hasReceivedGiftForEmailPermissions = true;
         }
      }
   }
}

