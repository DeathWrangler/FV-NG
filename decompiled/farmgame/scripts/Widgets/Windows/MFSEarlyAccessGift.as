package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.ExpansionEarlyAccessGiftingData;
   import Display.UI;
   import Transactions.TBuyAndSendPresent;
   
   public class MFSEarlyAccessGift extends MFSSendPaidGift
   {
      
      private var m_earlyAccessGifting:ExpansionEarlyAccessGiftingData;
      
      public function MFSEarlyAccessGift(earlyAcccess:ExpansionEarlyAccessGiftingData, completeCallback:Function)
      {
         this.m_earlyAccessGifting = earlyAcccess;
         m_giftItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_earlyAccessGifting.itemName);
         m_dialogURL = this.m_earlyAccessGifting.mainDialogAssetURL;
         super(m_giftItem,TBuyAndSendPresent.ITEMCONTEXT_EARLYACCESS,completeCallback,StatsTrackingConstants.MARKETPLACE_EA_GIFTING);
      }
      
      override protected function createObjectPreview(scale:Number, itemState:String) : void
      {
      }
      
      override protected function showGiftingSuccessWindow(friendList:Array) : void
      {
         UI.displayPopup(new EarlyAccessGiftingSuccess(friendList.length,m_giftItem,this.m_earlyAccessGifting.congratsDiaogAssetURL,m_successCallback),false);
      }
   }
}

