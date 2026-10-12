package Classes.MOTD
{
   import Classes.StorageBuilding;
   import Display.UI;
   
   public class MystreeBabiesMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private var m_itemName:String;
      
      private var m_itemPrice:int;
      
      public function MystreeBabiesMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams) && Boolean(currentMOTD.customWindowParams.item))
         {
            this.m_itemName = currentMOTD.customWindowParams.item;
         }
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams) && Boolean(currentMOTD.customWindowParams.cost))
         {
            this.m_itemPrice = currentMOTD.customWindowParams.cost;
         }
      }
      
      override protected function acceptMOTD() : void
      {
         var storageBuilding:StorageBuilding = null;
         super.acceptMOTD();
         var buildingNames:Array = ["animal_breeding_nursery_finished","animal_breeding_nursery"];
         var buildingObjects:Array = Global.world.getObjectsByNames(buildingNames);
         if(buildingObjects.length == 0)
         {
            UI.displayMiniMarketDialog(buildingNames);
         }
         else if(buildingObjects)
         {
            storageBuilding = buildingObjects[0];
            if(storageBuilding)
            {
               storageBuilding.displayStorageDialog();
            }
         }
      }
   }
}

