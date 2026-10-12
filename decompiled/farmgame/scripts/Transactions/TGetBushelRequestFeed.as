package Transactions
{
   public class TGetBushelRequestFeed extends TFarmTransaction
   {
      
      private var m_bushelItemCode:String = null;
      
      private var m_craftType:String = null;
      
      private var m_callback:Function = null;
      
      public function TGetBushelRequestFeed(bushelItemCode:String, craftType:String = null, callback:Function = null)
      {
         this.m_bushelItemCode = bushelItemCode;
         this.m_craftType = craftType;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onGetBushelRequestFeed",this.m_bushelItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result,this.m_bushelItemCode,this.m_craftType);
         }
      }
   }
}

