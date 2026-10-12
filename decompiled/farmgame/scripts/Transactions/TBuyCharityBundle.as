package Transactions
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Display.UI;
   
   public class TBuyCharityBundle extends TFarmTransaction
   {
      
      protected var m_item:FarmItem;
      
      private var m_callback:Function;
      
      protected var m_onBuyCallback:Function;
      
      private var m_expansionInProgressWindow:GenericPopup = null;
      
      private var m_price:int;
      
      public function TBuyCharityBundle(item:String, extraData:Object = null, onBuyCallback:Function = null)
      {
         super();
         this.m_onBuyCallback = onBuyCallback;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(extraData != null && extraData.price != null)
         {
            this.m_price = extraData.price;
         }
      }
      
      override public function perform() : void
      {
         Global.player.cash -= this.m_price;
         this.m_expansionInProgressWindow = UI.displayMessage("Please wait just a moment while we expand your farm!",GenericPopup.TYPE_MODAL,null,"",true);
         signedCall("ChristmasCharityBundleService.BuyBundle",this.m_item.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_expansionInProgressWindow)
         {
            this.m_expansionInProgressWindow.close();
            this.m_expansionInProgressWindow = null;
         }
         if(this.m_onBuyCallback != null)
         {
            this.m_onBuyCallback(result);
         }
      }
   }
}

