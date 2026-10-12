package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.FarmItem;
   
   public class EarlyAccessGiftingSuccess extends MarketplaceGiftingSuccess
   {
      
      public function EarlyAccessGiftingSuccess(numFriends:int, giftItem:FarmItem, dialogURL:String, closerCallback:Function = null)
      {
         m_DialogResource = dialogURL;
         super(numFriends,giftItem,closerCallback,StatsTrackingConstants.MARKETPLACE_EA_GIFTING);
      }
      
      override protected function showObjectPreview(scale:Number, itemState:String) : void
      {
      }
   }
}

