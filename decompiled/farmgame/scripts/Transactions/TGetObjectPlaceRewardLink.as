package Transactions
{
   public class TGetObjectPlaceRewardLink extends TFarmTransaction
   {
      
      private var m_itemName:String = "";
      
      private var m_callback:Function = null;
      
      public function TGetObjectPlaceRewardLink(itemName:String, callBack:Function = null)
      {
         super();
         this.m_itemName = itemName;
         this.m_callback = callBack;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.getObjectPlaceRewardLink",this.m_itemName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_callback)
            {
               this.m_callback(result.rewardUrl);
            }
         }
      }
   }
}

