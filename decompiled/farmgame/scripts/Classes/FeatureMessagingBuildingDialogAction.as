package Classes
{
   public class FeatureMessagingBuildingDialogAction implements IFeatureMessagingCustomAction
   {
      
      private var m_buildingItemCodes:Array;
      
      public function FeatureMessagingBuildingDialogAction(xml:XMLList)
      {
         var bldgXML:XML = null;
         super();
         this.m_buildingItemCodes = new Array();
         for each(bldgXML in xml)
         {
            this.m_buildingItemCodes.push(bldgXML.attribute("code").toString());
         }
      }
      
      public function perform() : void
      {
         var bldgCode:String = null;
         var worldInstances:Array = null;
         var instance:Object = null;
         if(this.m_buildingItemCodes.length > 0)
         {
            for each(bldgCode in this.m_buildingItemCodes)
            {
               worldInstances = Global.world.getObjectsByCode(bldgCode);
               if(worldInstances.length > 0)
               {
                  instance = worldInstances[0];
                  if(instance is StorageBuilding)
                  {
                     (instance as StorageBuilding).displayStorageDialog();
                     break;
                  }
               }
            }
         }
      }
   }
}

