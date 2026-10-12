package Classes.consumables
{
   import Classes.Consumable;
   import Classes.FeatureBuilding;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.ConsumableItem;
   
   public class CFeatureBuildingTicket extends Consumable
   {
      
      public static const CLASS_NAME:String = "CFeatureBuildingTicket";
      
      public function CFeatureBuildingTicket(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var buildingName:String = null;
         var worldObjects:Array = null;
         var worldObjectsLength:int = 0;
         var i:int = 0;
         var featureBuilding:FeatureBuilding = null;
         var buildingItem:BuildingItem = null;
         var item:ConsumableItem = m_item as ConsumableItem;
         if(item)
         {
            buildingName = item.buildingName;
            if(buildingName)
            {
               worldObjects = Global.world.getObjects();
               worldObjectsLength = int(worldObjects.length);
               for(i = 0; i < worldObjectsLength; i++)
               {
                  featureBuilding = worldObjects[i] as FeatureBuilding;
                  if(featureBuilding)
                  {
                     buildingItem = featureBuilding.getItem() as BuildingItem;
                     if(buildingItem.buildingName == buildingName)
                     {
                        featureBuilding.displayStorageDialog();
                     }
                  }
               }
            }
            else
            {
               GlobalEngine.assert(false,"Item is missing buildingName attribute.");
            }
         }
      }
   }
}

