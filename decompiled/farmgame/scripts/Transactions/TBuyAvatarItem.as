package Transactions
{
   import Classes.Avatar.AvatarItem;
   
   public class TBuyAvatarItem extends TFarmTransaction
   {
      
      private var m_avatarItem:AvatarItem;
      
      public function TBuyAvatarItem(avatarItem:AvatarItem)
      {
         this.m_avatarItem = avatarItem;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("AvatarService.buyAvatarItem",this.m_avatarItem.itemId);
      }
   }
}

