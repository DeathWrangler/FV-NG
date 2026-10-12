package Transactions
{
   public class TGetAskItemFriends extends TFarmTransaction
   {
      
      private const DEFAULT_REACTIVATION_START_DAY:int = 7;
      
      private const DEFAULT_REACTIVATION_END_DAY:int = 730;
      
      private var m_callback:Function;
      
      private var m_specs:Array;
      
      private var m_requestItemName:String;
      
      private var m_featureName:String;
      
      private var m_requestType:int;
      
      private var m_startDay:int;
      
      private var m_endDay:int;
      
      public function TGetAskItemFriends(requestType:int, featureName:String, requestItemName:String, specs:Array, callback:Function = null, startDay:int = 0, endDay:int = 0)
      {
         super();
         this.m_callback = callback;
         this.m_specs = specs;
         this.m_requestType = requestType;
         this.m_requestItemName = requestItemName;
         this.m_featureName = featureName;
         if(startDay == 0)
         {
            startDay = this.DEFAULT_REACTIVATION_START_DAY;
         }
         if(endDay == 0)
         {
            endDay = this.DEFAULT_REACTIVATION_START_DAY;
         }
         this.m_startDay = startDay;
         this.m_endDay = endDay;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getAskItemFriends",this.m_requestType,this.m_featureName,this.m_requestItemName,this.m_specs,this.m_startDay,this.m_endDay);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != this.m_callback)
         {
            this.m_callback(result);
         }
      }
   }
}

