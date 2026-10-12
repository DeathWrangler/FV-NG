package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class HybridSeedRequirement extends ItemRequirement
   {
      
      private const MAX_MASTERY_LEVEL:int = 2;
      
      private var m_associatedBuildingFriendlyName:String = null;
      
      public function HybridSeedRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
      }
      
      public function get hybridSeedCropName() : String
      {
         return m_item.name;
      }
      
      private function get associatedBuildingFriendlyName() : String
      {
         var associatedBuildingName:String = null;
         var buildingItem:FarmItem = null;
         if(this.m_associatedBuildingFriendlyName == null)
         {
            this.m_associatedBuildingFriendlyName = "";
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               associatedBuildingName = m_dataSource.getString("associatedBuilding");
            }
            else
            {
               associatedBuildingName = m_xml.@associatedBuilding;
            }
            buildingItem = Global.farmGameSettingsManager.getFarmItemByName(associatedBuildingName);
            if(buildingItem)
            {
               this.m_associatedBuildingFriendlyName = buildingItem.friendlyName;
            }
         }
         return this.m_associatedBuildingFriendlyName;
      }
      
      override public function check() : Boolean
      {
         var success:Boolean = false;
         var masteryCrop:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.hybridSeedCropName);
         if(masteryCrop)
         {
            if(Global.player.mastery.hasOwnProperty(masteryCrop.code))
            {
               if(Global.player.mastery[masteryCrop.code] >= this.MAX_MASTERY_LEVEL)
               {
                  success = true;
               }
            }
         }
         if(Global.player.hasSeed(this.hybridSeedCropName))
         {
            success = true;
         }
         return success;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.HYBRIDSEED;
      }
      
      override public function getLocalizationsParams() : Array
      {
         var result:Array = this.getLocalizationParamsMultiple();
         result.push(this.associatedBuildingFriendlyName);
         return result;
      }
      
      override public function getLocalizationParamsMultiple() : Array
      {
         var result:Array = null;
         var hybridSeedCropFriendlyName:String = "";
         var hybridSeedCrop:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.hybridSeedCropName);
         if(hybridSeedCrop)
         {
            hybridSeedCropFriendlyName = hybridSeedCrop.friendlyName;
         }
         return [hybridSeedCropFriendlyName];
      }
      
      override public function getReadableMessage() : String
      {
         var params:Array = this.getLocalizationsParams();
         return ZLocUtils.t("Dialogs","RequirementHybridSeed_single",{
            "seed":ZLocUtils.tk_pk(params[0]),
            "greenhouse":ZLocUtils.tk_pk(params[1])
         });
      }
      
      override public function getReadableMessageFromParams(paramsArray:Array) : String
      {
         var param:String = null;
         var params:Array = [];
         var hybridSeedNames:String = null;
         for each(param in paramsArray)
         {
            if(hybridSeedNames == null)
            {
               hybridSeedNames = "";
            }
            else
            {
               hybridSeedNames += ", ";
            }
            hybridSeedNames += param;
         }
         params.push(hybridSeedNames,this.associatedBuildingFriendlyName);
         return ZLocUtils.t("Dialogs","RequirementHybridSeed_multiple",{
            "seeds":ZLocUtils.tk_pk(params[0]),
            "greenhouse":ZLocUtils.tk_pk(params[1])
         });
      }
   }
}

