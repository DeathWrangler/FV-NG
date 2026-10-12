package Classes
{
   public class W2WFeatureState
   {
      
      private static const TIMESTAMP_KEY:String = "ts";
      
      private var m_initComplete:Boolean = false;
      
      private var m_lastSeenTimestamp:Number = 0;
      
      private var m_sentHistory:Object = {};
      
      private var m_receivedHistory:Object = {};
      
      private var m_playerHistory:Object = {};
      
      public function W2WFeatureState()
      {
         super();
      }
      
      public function initW2WState(resultInfo:Object) : void
      {
         this.m_lastSeenTimestamp = Number(resultInfo.lastseen);
         if(resultInfo.hasOwnProperty("sent"))
         {
            this.m_sentHistory = resultInfo.sent;
         }
         if(resultInfo.hasOwnProperty("received"))
         {
            this.m_receivedHistory = resultInfo.received;
         }
         if(resultInfo.hasOwnProperty("playerhistory"))
         {
            this.m_playerHistory = resultInfo.playerhistory;
         }
         this.m_initComplete = true;
      }
      
      public function get initComplete() : Boolean
      {
         return this.m_initComplete;
      }
      
      private function getFeatureKey(featureName:String, feedName:String) : String
      {
         return featureName + "_" + feedName;
      }
      
      public function getRecentlyReceived(featureName:String, feedName:String) : Array
      {
         var uid:String = null;
         var feedReceivedTS:Number = NaN;
         var result:Array = [];
         var key:String = this.getFeatureKey(featureName,feedName);
         if(this.m_receivedHistory.hasOwnProperty(key) && Boolean(this.m_receivedHistory[key]))
         {
            for(uid in this.m_receivedHistory[key])
            {
               feedReceivedTS = Number(this.m_receivedHistory[key][uid]);
               if(feedReceivedTS > this.m_lastSeenTimestamp)
               {
                  result.push(uid);
               }
            }
         }
         return result;
      }
      
      public function getRecentlyReceivedCount(featureName:String, feedName:String) : Number
      {
         return this.getRecentlyReceived(featureName,feedName).length;
      }
      
      public function getRecentlySent(featureName:String, feedName:String, uid:String) : Boolean
      {
         var sentUid:String = null;
         var rolloverSeconds:Number = NaN;
         var timestamp:Number = NaN;
         var serverTime:Number = NaN;
         var result:Boolean = false;
         var key:String = this.getFeatureKey(featureName,feedName);
         if(this.m_sentHistory[key])
         {
            for(sentUid in this.m_sentHistory[key])
            {
               if(sentUid.replace(":","") == uid)
               {
                  rolloverSeconds = Global.farmGameSettingsManager.getW2WRolloverSeconds(featureName);
                  timestamp = Number(this.m_sentHistory[key][sentUid][TIMESTAMP_KEY]);
                  serverTime = Math.round(GlobalEngine.serverTime / 1000);
                  if(timestamp + rolloverSeconds > serverTime)
                  {
                     result = true;
                  }
                  break;
               }
            }
         }
         return result;
      }
      
      public function setRecentlySent(featureName:String, feedName:String, uid:String, timestamp:Number) : void
      {
         var key:String = this.getFeatureKey(featureName,feedName);
         if(!this.m_sentHistory[key])
         {
            this.m_sentHistory[key] = {};
         }
         this.m_sentHistory[key][":" + uid] = {"ts":timestamp};
      }
   }
}

