package Managers
{
   import Classes.ZItem.FarmItem;
   
   public class FeatureOptionsInventoryManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "inventoryManager";
      
      public function FeatureOptionsInventoryManager(featureName:String = "inventoryManager")
      {
         super(featureName);
      }
      
      public static function getInstance(featureName:String = "inventoryManager") : FeatureOptionsInventoryManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,FeatureOptionsInventoryManager) as FeatureOptionsInventoryManager;
      }
      
      public function addCount(itemCode:String, count:Number) : void
      {
         var item:FarmItem = null;
         var currentCount:Number = NaN;
         var updatedCount:Number = NaN;
         if(Boolean(itemCode) && count > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item)
            {
               currentCount = this.getCount(itemCode);
               updatedCount = currentCount + count;
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,itemCode,updatedCount);
            }
         }
      }
      
      public function addCountByName(itemName:String, count:Number) : void
      {
         var item:FarmItem = null;
         var currentCount:Number = NaN;
         var updatedCount:Number = NaN;
         if(Boolean(itemName) && count > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               currentCount = this.getCountByName(itemName);
               updatedCount = currentCount + count;
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,item.code,updatedCount);
            }
         }
      }
      
      public function removeCount(itemCode:String, count:Number) : void
      {
         var item:FarmItem = null;
         var currentCount:Number = NaN;
         var updatedCount:Number = NaN;
         if(Boolean(itemCode) && count > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(item)
            {
               currentCount = this.getCount(itemCode);
               updatedCount = currentCount - count;
               if(updatedCount < 0)
               {
                  updatedCount = 0;
               }
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,itemCode,updatedCount);
            }
         }
      }
      
      public function removeCountByName(itemName:String, count:Number) : void
      {
         var item:FarmItem = null;
         var currentCount:Number = NaN;
         var updatedCount:Number = NaN;
         if(Boolean(itemName) && count > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               currentCount = this.getCountByName(itemName);
               updatedCount = currentCount - count;
               if(updatedCount < 0)
               {
                  updatedCount = 0;
               }
               FeatureOptionsManager.getInstance().setFeatureOption(m_featureName,item.code,updatedCount);
            }
         }
      }
      
      public function hasItemEntryInInventory(itemCode:String) : Boolean
      {
         var entry:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,itemCode) as Number;
         return entry != null;
      }
      
      public function getCount(itemCode:String) : Number
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,itemCode) as Number;
      }
      
      public function getCountByName(itemName:String) : Number
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         return FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,itemCode) as Number;
      }
      
      public function limitReachedForItem(itemCode:String, count:Number = 0) : Boolean
      {
         var result:Boolean = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            if(count == 0)
            {
               count = this.getCount(itemCode);
            }
            if(count >= item.limit)
            {
               result = true;
            }
         }
         return result;
      }
   }
}

