package Managers
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import mx.utils.StringUtil;
   
   public class DailyStatsManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "DailyStats";
      
      private static const SERVICE_NAME:String = "DailyStatsService";
      
      private static const KEY_LAST_SAVED_DATE:String = "key_last_saved_date";
      
      public static const ACTION_HARVEST:String = "harvest";
      
      public static const ACTION_CRAFT:String = "craft_action";
      
      public static const SOURCE_CROP:String = "crop";
      
      public static const SOURCE_CRAFT_SHOP:String = "craft_shop";
      
      public static const SOURCE_CRAFTING_COTTAGE:String = "crafting_cottage";
      
      public function DailyStatsManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
      }
      
      private static function getForamattedDateKey() : String
      {
         var date:Date = new Date();
         return StringUtil.substitute("{0}-{1}-{2}",date.getUTCFullYear(),date.getUTCMonth() + 1,date.getUTCDate());
      }
      
      private static function getInitializedFeatureData() : Object
      {
         var featureData:Object = {};
         var key:String = getForamattedDateKey();
         featureData[ACTION_HARVEST] = {};
         featureData[ACTION_HARVEST][SOURCE_CROP] = 0;
         featureData[ACTION_CRAFT] = {};
         featureData[ACTION_CRAFT][SOURCE_CRAFT_SHOP] = 0;
         featureData[ACTION_CRAFT][SOURCE_CRAFTING_COTTAGE] = 0;
         featureData[KEY_LAST_SAVED_DATE] = key;
         return featureData;
      }
      
      public static function getInstance(featureName:String = "DailyStats") : DailyStatsManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,DailyStatsManager) as DailyStatsManager;
      }
      
      private static function dispatchCountConditionally(source:String, action:String, date:String, count:int) : void
      {
         if(count > 0)
         {
            FarmStatsManager.count("farm_action",source,action,date,"","",count);
         }
      }
      
      private function getFeatureData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = getInitializedFeatureData();
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function incrementCounter(source:String, action:String, count:int) : void
      {
         var featureData:Object = null;
         if(this.shouldDispatch())
         {
            this.dispatchCounts();
         }
         featureData = this.getFeatureData();
         var key:String = featureData[KEY_LAST_SAVED_DATE];
         if(!featureData.hasOwnProperty(action))
         {
            return;
         }
         if(!featureData[action].hasOwnProperty(source))
         {
            return;
         }
         var oldCount:int = int(featureData[action][source]);
         featureData[action][source] = oldCount + count;
         setFeatureData(featureData);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"incrementCounter",null,[m_featureName,source,action,count,key]),true);
      }
      
      public function shouldDispatch() : Boolean
      {
         var featureData:Object = this.getFeatureData();
         return featureData[KEY_LAST_SAVED_DATE] != getForamattedDateKey();
      }
      
      private function resetCounter() : void
      {
         setFeatureData(getInitializedFeatureData());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"resetCounter",null,[m_featureName]),true);
      }
      
      public function dispatchCounts() : void
      {
         var featureData:Object = null;
         var action:String = null;
         var source:String = null;
         featureData = this.getFeatureData();
         var lastSavedDate:String = featureData[KEY_LAST_SAVED_DATE];
         var actions:Array = [ACTION_HARVEST,ACTION_CRAFT];
         for(var i:int = 0; i < actions.length; i++)
         {
            action = actions[i];
            if(featureData.hasOwnProperty(action))
            {
               for(source in featureData[action])
               {
                  if(featureData[action].hasOwnProperty(source))
                  {
                     dispatchCountConditionally(source,action,lastSavedDate,featureData[action][source]);
                  }
               }
            }
         }
         this.resetCounter();
      }
   }
}

