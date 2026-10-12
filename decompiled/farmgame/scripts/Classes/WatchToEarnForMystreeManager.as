package Classes
{
   import Engine.Managers.TransactionManager;
   import Managers.MystreeReskinManagerWithEMH;
   import Transactions.TGenericTransaction;
   
   public class WatchToEarnForMystreeManager extends WatchToEarnManager
   {
      
      private static var s_instance:WatchToEarnForMystreeManager;
      
      public static const W2E_MYSTREE_SLOT:String = "WEB_FARM_INC_BH_PREMIUM_1";
      
      public static const STAT_COUNTER:String = "w2e_mystree";
      
      public static const STAT_CLICK:String = "click";
      
      private static var m_featureName:String = "mystree_v9";
      
      private static const SERVICE_CLASS:String = "MystreeReskinService";
      
      protected static const ACTION_SPEEDUP_SAMPLING_WITH_EMH:String = "speedUpSaplingsFromWatchingAdsWithEMH";
      
      public function WatchToEarnForMystreeManager()
      {
         super();
      }
      
      public static function onSlotCompleteMystree() : void
      {
         MystreeReskinManagerWithEMH.getInstance(m_featureName).setCountAndTimeStamp();
         MystreeReskinManagerWithEMH.getInstance(m_featureName).updateSaplingTend();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_SPEEDUP_SAMPLING_WITH_EMH,null,[m_featureName]));
      }
   }
}

