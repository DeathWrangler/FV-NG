package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   
   public class SeedPackageRequirement extends ItemRequirement
   {
      
      private const SEED_PACKAGE_IDENTIFIER:String = "_seedpackage";
      
      private var m_seedPackageName:String;
      
      private var m_seedName:String;
      
      public function SeedPackageRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_seedPackageName = m_dataSource.getString("name");
         }
         else
         {
            this.m_seedPackageName = xml.@name;
         }
         this.m_seedName = this.m_seedPackageName.slice(0,this.m_seedPackageName.search(this.SEED_PACKAGE_IDENTIFIER));
      }
      
      public function get seedPackageName() : String
      {
         return this.m_seedPackageName;
      }
      
      override public function check() : Boolean
      {
         var success:Boolean = false;
         if(Global.player.hasSeed(this.m_seedName))
         {
            success = true;
         }
         return success;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.SEEDPACKAGE;
      }
      
      override public function getLocalizationsParams() : Array
      {
         var result:Array = this.getLocalizationParamsMultiple();
         result.unshift(m_item.friendlyName);
         return result;
      }
      
      override public function getLocalizationParamsMultiple() : Array
      {
         var result:Array = null;
         var seedpackageFriendlyName:String = "";
         var seedPackage:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_seedPackageName);
         if(seedpackageFriendlyName)
         {
            seedpackageFriendlyName = seedPackage.friendlyName;
         }
         return [seedpackageFriendlyName];
      }
      
      override public function getReadableMessage() : String
      {
         var params:Array = this.getLocalizationsParams();
         return ZLocUtils.t("Dialogs","RequirementSeedPackage_single");
      }
      
      override public function getReadableMessageFromParams(paramsArray:Array) : String
      {
         var param:String = null;
         var seedPackage:FarmItem = null;
         var seedpackageFriendlyName:String = null;
         var params:Array = [];
         var seedPackageNames:String = null;
         for each(param in paramsArray)
         {
            if(seedPackageNames == null)
            {
               seedPackageNames = "";
            }
            else
            {
               seedPackageNames += "\n";
            }
            seedPackageNames += param;
         }
         seedPackage = Global.farmGameSettingsManager.getFarmItemByName(this.m_seedPackageName);
         seedpackageFriendlyName = "";
         if(seedpackageFriendlyName)
         {
            seedpackageFriendlyName = seedPackage.friendlyName;
         }
         params.push(seedpackageFriendlyName,seedPackageNames);
         return ZLocUtils.t("Dialogs","RequirementSeedPackage_multiple");
      }
   }
}

