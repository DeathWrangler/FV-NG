package Managers
{
   import Classes.util.ExternalUtil;
   import flash.display.StageDisplayState;
   import flash.external.ExternalInterface;
   
   public class Requests2Manager
   {
      
      public function Requests2Manager()
      {
         super();
      }
      
      public static function sendGift(requestData:String, requestMessage:String, requestTitle:String, uids:Array, statsSource:String, callback:Function) : void
      {
         if(uids.length > 0)
         {
            if(Global.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
               Global.stage.displayState = StageDisplayState.NORMAL;
            }
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("fbresponseHandler",callback);
               ExternalUtil.instance.call("FarmNS.Request2Manager.sendRequestsFromFlash",requestData,requestMessage,requestTitle,uids,statsSource);
            }
         }
      }
   }
}

