package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class BuildingRequirement extends ItemRequirement
   {
      
      private var m_buildingName:String;
      
      private var m_buildingCount:uint;
      
      public function BuildingRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_buildingName = m_dataSource.getString("name");
            this.m_buildingCount = uint(m_dataSource.getInt("quantity"));
         }
         else
         {
            this.m_buildingName = xml.@name;
            this.m_buildingCount = uint(xml.@quantity);
         }
      }
      
      override public function check() : Boolean
      {
         var result:Array = Global.world.getObjectsByNames([this.m_buildingName]);
         if(Boolean(result) && result.length >= this.m_buildingCount)
         {
            return true;
         }
         return false;
      }
      
      override public function getReadableMessage() : String
      {
         var neededItemFriendlyName:String = this.m_buildingName;
         var neededItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_buildingName);
         if(neededItem)
         {
            neededItemFriendlyName = neededItem.friendlyName;
         }
         var quantity:String = this.m_buildingCount == 1 ? "" : this.m_buildingCount.toString();
         return ZLocUtils.t("Dialogs","RequirementBuilding",{
            "quantity":quantity,
            "item":ZLocUtils.tk_pk(neededItemFriendlyName,"",this.m_buildingCount)
         });
      }
   }
}

