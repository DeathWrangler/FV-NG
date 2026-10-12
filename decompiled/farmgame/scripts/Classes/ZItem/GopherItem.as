package Classes.ZItem
{
   import DataSources.BaseDataSource;
   import Managers.CaptureFeatureManager;
   
   public class GopherItem extends FarmItem
   {
      
      private var m_loadedGopherSettingsData:Boolean = false;
      
      private var m_requiredBuildingLevel:int = -1;
      
      private var m_requiredTreats:int = -1;
      
      private var m_featureName:String = null;
      
      public function GopherItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      private function loadGameSettingsData() : void
      {
         this.m_featureName = CaptureFeatureManager.instance.getFeatureNameFromItemName(m_name);
         var data:XML = CaptureFeatureManager.instance.getItemData(this.m_featureName,name);
         if(data)
         {
            this.m_requiredBuildingLevel = parseInt(data.requirements[0].@building_level.toString());
            this.m_requiredTreats = parseInt(data.requirements[0].@treats.toString());
            this.m_loadedGopherSettingsData = true;
         }
      }
      
      public function get requiredBuildingLevel() : int
      {
         if(!this.m_loadedGopherSettingsData)
         {
            this.loadGameSettingsData();
         }
         return this.m_requiredBuildingLevel;
      }
      
      public function get requiredTreats() : int
      {
         if(!this.m_loadedGopherSettingsData)
         {
            this.loadGameSettingsData();
         }
         return this.m_requiredTreats;
      }
      
      public function getCaptureCount() : int
      {
         var captureCounts:Object = CaptureFeatureManager.instance.getCapturedBreakdown(this.m_featureName);
         var count:int = 0;
         if(captureCounts[name])
         {
            count = int(captureCounts[name]);
         }
         return count;
      }
   }
}

