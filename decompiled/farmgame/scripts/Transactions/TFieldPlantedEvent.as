package Transactions
{
   public class TFieldPlantedEvent extends TFarmTransaction
   {
      
      private var m_seedType:String = null;
      
      public function TFieldPlantedEvent(seedType:String = null)
      {
         super();
         if(seedType != null)
         {
            this.m_seedType = seedType;
         }
         else
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserFeedService.logFieldPlantedEvent",this.m_seedType);
      }
   }
}

