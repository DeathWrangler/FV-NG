package Classes
{
   import Classes.util.FarmGameUtil;
   import Managers.UnlimitedPacksManager;
   
   public class ManagedSale
   {
      
      protected var m_internalObject:Object;
      
      public function ManagedSale(internalObject:Object)
      {
         var saleEndTime:int = 0;
         super();
         this.m_internalObject = internalObject;
         if(this.m_internalObject.hasOwnProperty("prereqType") && this.m_internalObject.prereqType == "unlimited_pack")
         {
            saleEndTime = UnlimitedPacksManager.getInstance().getSaleEndTimeForUser();
            if(saleEndTime)
            {
               saleEndTime = Math.min(saleEndTime,this.m_internalObject.endDate);
               this.m_internalObject.endDate = saleEndTime;
            }
         }
      }
      
      public function get price() : int
      {
         return this.m_internalObject.salePrice;
      }
      
      public function get timeLeft() : Number
      {
         var now:int = 0;
         var rv:Number = 0;
         if(this.isActive())
         {
            now = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            rv = this.m_internalObject["endDate"] - now;
         }
         return rv;
      }
      
      public function isActive() : Boolean
      {
         var now:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return now >= this.m_internalObject["startDate"] && now <= this.m_internalObject["endDate"];
      }
   }
}

