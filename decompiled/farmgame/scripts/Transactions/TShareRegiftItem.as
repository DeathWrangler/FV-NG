package Transactions
{
   import Classes.ZItem.FarmItem;
   
   public class TShareRegiftItem extends TFarmTransaction
   {
      
      private var m_itemCode:String;
      
      private var m_quantity:int;
      
      public function TShareRegiftItem(itemCode:String, quantity:int)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_quantity = quantity;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.giftStoredGiftBoxItems",this.m_itemCode,this.m_quantity);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var rewardLink:String = null;
         var item:FarmItem = null;
         var params:Object = null;
         if(result)
         {
            rewardLink = result["rewardLink"];
            if(rewardLink != null)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
               params = {
                  "actor":Global.player.name,
                  "images":[{
                     "src":item.icon,
                     "href":Config.SN_APP_URL + rewardLink
                  }],
                  "reward_link":rewardLink,
                  "itemCount":this.m_quantity,
                  "itemName":item.friendlyName
               };
               GlobalEngine.socialNetwork.publishFeedStory("ShareRegift",params,[],false);
            }
         }
      }
   }
}

