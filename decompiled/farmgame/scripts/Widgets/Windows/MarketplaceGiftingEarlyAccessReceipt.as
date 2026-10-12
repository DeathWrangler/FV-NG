package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.ExpansionEarlyAccessGiftingData;
   import Classes.ZItem.FarmItem;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.MovieClip;
   
   public class MarketplaceGiftingEarlyAccessReceipt extends MarketplaceGiftingReceipt
   {
      
      public function MarketplaceGiftingEarlyAccessReceipt(senderUid:String, giftItem:FarmItem, returnItem:FarmItem, closeCallback:Function)
      {
         var settings:ExpansionEarlyAccessGiftingData = Global.farmGameSettingsManager.getEarlyAccessGiftingExpansion();
         if(settings)
         {
            m_DialogResource = settings.giftDialogAssetURL;
         }
         super(senderUid,giftItem,returnItem,closeCallback,StatsTrackingConstants.MARKETPLACE_EA_GIFTING);
      }
      
      override protected function createObjectPreview(item:FarmItem, element:MovieClip, scaleFactor:Number) : ObjectPreviewFrame
      {
         if(item != m_giftItem)
         {
            super.createObjectPreview(item,element,scaleFactor);
         }
         return null;
      }
   }
}

