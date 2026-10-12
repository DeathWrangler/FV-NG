package Transactions
{
   public class TGrantDowngradeCoins extends TWorldState
   {
      
      private var m_itemName:String = "";
      
      private var m_campaignName:String = "";
      
      public function TGrantDowngradeCoins(campaignName:String, itemName:String)
      {
         super(null);
         this.m_itemName = itemName;
         this.m_campaignName = campaignName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.grantDowngradeCoins",this.m_campaignName,this.m_itemName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(result.success)
            {
               if(result.hasOwnProperty("coins") && result.coins > 0)
               {
                  Global.player.gold += result.coins;
               }
            }
         }
         this.m_campaignName = "";
         this.m_itemName = "";
      }
   }
}

