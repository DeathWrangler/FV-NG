package Managers
{
   import Classes.Constants.Experiments;
   import Classes.ManagedSale;
   import Classes.ZItem.FarmItem;
   import flash.utils.Dictionary;
   
   public class ManagedSalesManager
   {
      
      protected var m_sales:Dictionary = new Dictionary();
      
      public function ManagedSalesManager()
      {
         super();
      }
      
      public static function getSaleObject(farmItem:FarmItem) : ManagedSale
      {
         var managedSale:ManagedSale = Global.managedSalesManager.getSaleObject(farmItem);
         var vipSale:ManagedSale = Global.vipSalesManager.getSaleObject(farmItem);
         var preferredSale:ManagedSale = null;
         if(Boolean(managedSale) && Boolean(vipSale) && Global.vipSalesManager.isEnabled())
         {
            if(vipSale.price < managedSale.price)
            {
               preferredSale = vipSale;
            }
            else
            {
               preferredSale = managedSale;
            }
         }
         else if(Boolean(vipSale) && Global.vipSalesManager.isEnabled())
         {
            preferredSale = vipSale;
         }
         else
         {
            preferredSale = managedSale;
         }
         return preferredSale;
      }
      
      public function setManagedSales(sales:Object) : void
      {
         var itemName:String = null;
         for(itemName in sales)
         {
            this.m_sales[itemName] = new ManagedSale(sales[itemName]);
         }
      }
      
      public function getSaleObject(item:FarmItem) : ManagedSale
      {
         var result:ManagedSale = null;
         if(item.buyableWithCash() && this.m_sales.hasOwnProperty(item.cashName))
         {
            result = this.m_sales[item.cashName];
         }
         return result;
      }
      
      public function getPresortList() : Array
      {
         var sale:String = null;
         var result:Array = new Array();
         for(sale in this.m_sales)
         {
            result.push(sale);
         }
         return result;
      }
      
      public function getSaleSubTypes() : Array
      {
         var saleItemName:String = null;
         var farmItem:FarmItem = null;
         var marketEntriesTypeArray:Object = null;
         var subType:String = null;
         var typeArray:Array = null;
         var result:Array = new Array();
         result.push("all");
         var subTypeSet:Dictionary = new Dictionary();
         for(saleItemName in this.m_sales)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(saleItemName);
            if(Boolean(farmItem) && Boolean(farmItem.meetsWorldRestrictions()) && farmItem.isVisible)
            {
               marketEntriesTypeArray = farmItem.market3EntriesTypeArray;
               subType = null;
               for each(typeArray in marketEntriesTypeArray)
               {
                  subType = typeArray[FarmItem.TYPE_ARRAY_TYPE_INDEX];
                  if(subType != "" && !subTypeSet.hasOwnProperty(subType))
                  {
                     subTypeSet[subType] = 1;
                     result.push(subType);
                  }
               }
            }
         }
         return result;
      }
      
      public function hasValidOnSaleItems() : Boolean
      {
         var key:String = null;
         var item:FarmItem = null;
         var result:Boolean = false;
         for(key in this.m_sales)
         {
            if(key != null)
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(key);
               if(Boolean(item) && Boolean(item.meetsWorldRestrictions()) && item.isVisible)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isEnabled() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MANAGED_SALE_TAB) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
      }
   }
}

