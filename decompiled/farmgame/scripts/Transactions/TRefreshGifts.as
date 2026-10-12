package Transactions
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Quest.FarmQuestManager;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.OrganicFertilizerHelper;
   
   public class TRefreshGifts extends TFarmTransaction
   {
      
      private static const MAX_RETRY_COUNT:int = 5;
      
      public static const SERVER_METHOD:String = "getGifts";
      
      private static const USE_IN_FLIGHT_COUNTER_RUNTIME:String = "REFRESH_GIFTS_COUNTER";
      
      private static var m_transactionsInFlight:int = 0;
      
      private var m_storageData:Object = null;
      
      private var m_callback:Function = null;
      
      private var m_initialGiftboxVersion:int;
      
      private var m_retryCount:int;
      
      private var m_shouldAcceptChanges:Boolean = true;
      
      public function TRefreshGifts(callback:Function = null, retryCount:int = 0)
      {
         UI.closeAndLockGifts();
         if(Global.flashHotParams[USE_IN_FLIGHT_COUNTER_RUNTIME])
         {
            ++m_transactionsInFlight;
         }
         this.m_callback = callback;
         this.m_initialGiftboxVersion = Global.player.giftsVersion;
         this.m_retryCount = retryCount;
         super();
      }
      
      public static function isRefreshing() : Boolean
      {
         return m_transactionsInFlight > 0;
      }
      
      override public function perform() : void
      {
         signedCall("UserService." + SERVER_METHOD);
      }
      
      override protected function onComplete(result:Object) : void
      {
         --m_transactionsInFlight;
         m_transactionsInFlight = Math.max(m_transactionsInFlight,0);
         if(this.m_initialGiftboxVersion != Global.player.giftsVersion)
         {
            if(this.m_retryCount < MAX_RETRY_COUNT)
            {
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CHECK_GIFTBOX_CLOBBERING) > 0)
               {
                  this.m_shouldAcceptChanges = false;
               }
               FarmStatsManager.featureSample("errors","giftbox_oos","retry_" + this.m_retryCount.toString());
            }
            else
            {
               FarmStatsManager.featureSample("errors","giftbox_oos","max_retries_met");
            }
         }
         if(this.m_shouldAcceptChanges)
         {
            if(Boolean(result) && Boolean(result.storageData))
            {
               this.m_storageData = result.storageData;
               Global.player.refreshGiftBox(result.storageData);
               FarmQuestManager.getInstance().processTransactionOnServerComplete(new TransactionEvent(TransactionEvent.COMPLETED,this));
            }
            if(m_transactionsInFlight == 0)
            {
               UI.unlockGifts();
            }
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
            StatsManager.sample(10,OrganicFertilizerHelper.FEATURE_NAME,StatsTrackingConstants.GIFTBOX_COUNT,OrganicFertilizerHelper.getNumOrganicFertilizerInGiftbox().toString());
         }
         else
         {
            TransactionManager.addTransaction(new TRefreshGifts(this.m_callback,this.m_retryCount + 1));
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = null;
         if(this.m_shouldAcceptChanges)
         {
            result = new Object();
            result.method = SERVER_METHOD;
            result.storageData = this.m_storageData;
         }
         else
         {
            result = super.getTransactionData();
         }
         return result;
      }
   }
}

