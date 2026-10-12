package Classes
{
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   import flash.filters.GlowFilter;
   
   public class BuildingPart extends LootableDecoration
   {
      
      private var m_buildingTypes:Array;
      
      public function BuildingPart(itemName:String = null)
      {
         var buildingTypesArr:Array = null;
         var i:int = 0;
         var buildingTypes:XMLList = null;
         var type:XML = null;
         this.m_buildingTypes = new Array();
         super(itemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            buildingTypesArr = this.getItem().getArrayFromDataSource("component","buildingType");
            for(i = 0; i < buildingTypesArr.length; i++)
            {
               this.m_buildingTypes.push((buildingTypesArr[i] as BaseDataSource).toString());
            }
         }
         else
         {
            buildingTypes = this.getItem().xml.component.buildingType;
            for each(type in buildingTypes)
            {
               this.m_buildingTypes.push(type.toString());
            }
         }
      }
      
      public static function newStandardGlowFilter() : GlowFilter
      {
         return new GlowFilter(16776960,1,8,8,20);
      }
      
      override protected function getMenuItems() : Array
      {
         return [];
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         return null;
      }
      
      public function get buildingTypes() : Array
      {
         return this.m_buildingTypes;
      }
   }
}

