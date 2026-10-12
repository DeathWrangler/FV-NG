package Transactions
{
   import Classes.ZItem.FarmItem;
   
   public class TShareFlashGiftFeed extends TFarmTransaction
   {
      
      private var m_item:FarmItem = null;
      
      private var m_callback:Function = null;
      
      public function TShareFlashGiftFeed(item:FarmItem, callback:Function)
      {
         super();
         this.m_item = item;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FlashGiftService.shareFlashGiftFeed",this.m_item.name);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

