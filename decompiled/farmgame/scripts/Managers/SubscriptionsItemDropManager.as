package Managers
{
   import Classes.util.FarmGameUtil;
   import flash.utils.Dictionary;
   
   public class SubscriptionsItemDropManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "subscriptionDiamondDrops";
      
      private var m_eligible:Boolean = false;
      
      private var m_items:Dictionary;
      
      private var m_activeIndex:Number = -1;
      
      public function SubscriptionsItemDropManager(featureName:String = "subscriptionDiamondDrops")
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String = "subscriptionDiamondDrops") : SubscriptionsItemDropManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,SubscriptionsItemDropManager) as SubscriptionsItemDropManager;
      }
      
      public function getCurrentDropItemName() : String
      {
         var activeIndex:Number = NaN;
         var result:String = "";
         var startDate:Number = this.getStartDate();
         var itemsList:Dictionary = this.getItemList();
         if(Boolean(itemsList) && startDate > 0)
         {
            activeIndex = this.getActiveIndex();
            if(Boolean(itemsList[activeIndex]) && Boolean(itemsList[activeIndex].name))
            {
               result = itemsList[activeIndex].name;
            }
         }
         return result;
      }
      
      private function getFeatureConfig(featureName:String = "subscriptionDiamondDrops") : XML
      {
         return m_featureConfig;
      }
      
      private function getActiveIndex() : Number
      {
         return this.m_activeIndex;
      }
      
      public function setActiveIndex(activeIndex:Number) : void
      {
         this.m_activeIndex = activeIndex;
      }
      
      private function getStartDate() : Number
      {
         var startDate:Number = 0;
         if(m_featureConfig)
         {
            startDate = FarmGameUtil.synchronizedDateToNumber(m_featureConfig.@born) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         return startDate;
      }
      
      private function getItemList() : Dictionary
      {
         var result:Dictionary = null;
         var featureConfig:XML = null;
         var item:XML = null;
         var configObj:Object = null;
         if(!this.m_items)
         {
            result = new Dictionary();
            featureConfig = this.getFeatureConfig();
            if(featureConfig)
            {
               for each(item in featureConfig.items.item)
               {
                  if(item)
                  {
                     configObj = {
                        "index":Number(item.@index.toString()),
                        "name":item.@name.toString(),
                        "count":Number(item.@count.toString())
                     };
                     result[configObj.index] = configObj;
                  }
               }
            }
            this.m_items = result;
         }
         return this.m_items;
      }
      
      public function setEligibileToClaim(value:Boolean) : void
      {
         this.m_eligible = value;
      }
      
      public function eligibleToClaim() : Boolean
      {
         return this.m_eligible;
      }
   }
}

