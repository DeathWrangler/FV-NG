package Transactions
{
   import Classes.storage.CraftedItem;
   
   public class TUseCraftedGood extends TFarmTransaction
   {
      
      private var m_craftedItem:CraftedItem;
      
      private var m_callback:Function = null;
      
      public function TUseCraftedGood(craftedItem:CraftedItem, callback:Function = null)
      {
         super();
         this.m_craftedItem = craftedItem;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onUseCraftedGood",this.m_craftedItem.itemKey);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}

