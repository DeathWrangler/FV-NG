package Transactions
{
   public class TDragonBreeding extends TFarmTransaction
   {
      
      private var m_itemCode:String;
      
      private var m_callback:Function;
      
      private var m_type:String;
      
      public function TDragonBreeding(itemCode:String, callback:Function, type:String)
      {
         this.m_itemCode = itemCode;
         this.m_callback = callback;
         this.m_type = type;
         super();
      }
      
      override public function perform() : void
      {
         switch(this.m_type)
         {
            case "fire":
               signedCall("DragonBreedingService.onAskForFire",this.m_itemCode);
               break;
            case "herbs":
               signedCall("DragonBreedingService.onAskForHerbs",this.m_itemCode);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && Boolean(result.rewardLink))
         {
            this.m_callback(result.rewardLink);
         }
      }
   }
}

