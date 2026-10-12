package Transactions
{
   public class PreFetchTInitUser extends TFarmTransaction
   {
      
      protected var m_firstName:String;
      
      private var m_timezoneOffset:Number;
      
      private var m_onResponseReceivedCallback:Function;
      
      public function PreFetchTInitUser(firstName:String, onResponseReceivedCallback:Function)
      {
         super();
         m_preFetch = true;
         this.m_firstName = firstName;
         this.m_timezoneOffset = this.getTimezoneOffset();
         this.m_onResponseReceivedCallback = onResponseReceivedCallback;
      }
      
      override public function isInitTransaction() : Boolean
      {
         return true;
      }
      
      override public function perform() : void
      {
         var flashControllerInit:String = GlobalEngine.getFlashVar(Global.loadingMetricsRecorder.KEY_LOADTIME_FLASHCONTROLLER) as String;
         Global.loadingMetricsRecorder.addTimingMetric(Global.loadingMetricsRecorder.KEY_LOADTIME_FLASHCONTROLLER,flashControllerInit);
         var loadWorld:Boolean = Config.DEBUG_MODE;
         signedCall("UserService.initUser",this.m_firstName,this.m_timezoneOffset,loadWorld,false,flashControllerInit);
      }
      
      private function getTimezoneOffset() : Number
      {
         var now:Date = new Date();
         return now.timezoneOffset;
      }
      
      override public function postPrefetchActions(result:Object) : void
      {
         this.m_onResponseReceivedCallback(result);
      }
   }
}

