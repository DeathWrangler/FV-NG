package Transactions
{
   public class TIntervalActionCount extends TFarmTransaction
   {
      
      private var m_flagName:String;
      
      private var m_timeInterval:int;
      
      public function TIntervalActionCount(flagName:String, timeInterval:int)
      {
         super();
         this.m_flagName = flagName;
         this.m_timeInterval = timeInterval;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.incrementIntervalActionCount",this.m_flagName,this.m_timeInterval);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("actionCount"))
         {
            Global.player.setActionCount(this.m_flagName,result.actionCount);
         }
      }
   }
}

