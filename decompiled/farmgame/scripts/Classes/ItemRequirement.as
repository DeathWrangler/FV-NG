package Classes
{
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   
   public class ItemRequirement
   {
      
      public static const SECTION:String = "ItemRequirement";
      
      public static const COMPARE_TYPE_ANY:String = "any";
      
      public static const COMPARE_TYPE_ALL:String = "all";
      
      protected var m_xml:XML;
      
      protected var m_dataSource:BaseDataSource;
      
      protected var m_item:FarmItem;
      
      private var m_requirementTypes:Array = [BuildingRequirement,MasteryRequirement,SeedPackageRequirement,HybridSeedRequirement,PlatformRequirement,WorldRequirement,WorldLicenseRequirement,FriendSetRequirement,BuffTimeExpiredRequirement,SuperCropRequirement];
      
      public function ItemRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super();
         if(xml)
         {
            this.m_xml = xml;
         }
         else if(dataSource)
         {
            this.m_dataSource = dataSource;
         }
         if(item)
         {
            this.m_item = item;
         }
      }
      
      public function check() : Boolean
      {
         GlobalEngine.log(SECTION,"check() function not overridden ");
         return true;
      }
      
      public function shouldLockGiftbox() : Boolean
      {
         return false;
      }
      
      public function shouldLockCashItem() : Boolean
      {
         return false;
      }
      
      public function getMarketUnlockString() : String
      {
         return null;
      }
      
      public function get identifier() : String
      {
         return SECTION;
      }
      
      public function getLocalizationsParams() : Array
      {
         GlobalEngine.log(SECTION,"getLocalizationsParams() function not overridden ");
         return null;
      }
      
      public function getLocalizationParamsMultiple() : Array
      {
         GlobalEngine.log(SECTION,"getLocalizationParamsMultiple() function not overridden ");
         return null;
      }
      
      public function getReadableMessage() : String
      {
         GlobalEngine.log(SECTION,"readableMessage() function not overridden ");
         return "";
      }
      
      public function getShortReadableMessage(marketCardDesc:String = "") : String
      {
         GlobalEngine.log(SECTION,"getShortReadableMessage() function not overridden ");
         return "";
      }
      
      public function getReadableMessageFromParams(paramsArray:Array) : String
      {
         GlobalEngine.log(SECTION,"getReadableMessageFromParams() function not overridden ");
         return "";
      }
   }
}

