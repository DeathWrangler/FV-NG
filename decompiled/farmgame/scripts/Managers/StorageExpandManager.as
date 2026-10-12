package Managers
{
   import Classes.ChickenCoopBuilding;
   import Classes.StorageBuilding;
   import Display.InventoryWithdrawal;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TUpgradeStorage;
   
   public class StorageExpandManager
   {
      
      private static var m_instance:StorageExpandManager = null;
      
      public function StorageExpandManager()
      {
         super();
      }
      
      public static function getInstance() : StorageExpandManager
      {
         if(m_instance == null)
         {
            m_instance = new StorageExpandManager();
         }
         return m_instance;
      }
      
      public function updateStorageExpansionData(storageBuildingId:int) : void
      {
         var storageBuilding:StorageBuilding = null;
         var storageBuildings:Array = null;
         var idx:int = 0;
         if(storageBuildingId > 0)
         {
            storageBuilding = Global.world.getObjectById(storageBuildingId) as StorageBuilding;
         }
         else
         {
            storageBuildings = Global.world.getObjectsByClass(StorageBuilding);
            if(storageBuildings.length > 0)
            {
               storageBuilding = storageBuildings[0];
               for(idx = 0; idx < storageBuildings.length; idx++)
               {
                  if(Boolean(storageBuildings[idx].hasOwnProperty("buildingReady")) && Boolean(storageBuildings[idx].buildingReady))
                  {
                     storageBuildings[idx].buildingReady.owner.getFeatureReadyState();
                  }
               }
            }
         }
         if(storageBuilding)
         {
            TransactionManager.addTransaction(new TUpgradeStorage(storageBuilding,null,"update",this.onStorageUpdate));
         }
      }
      
      private function onStorageUpdate() : void
      {
         var currentTime:Number = NaN;
         var expired:Boolean = false;
         var completed:Boolean = false;
         var building:StorageBuilding = null;
         var iw:InventoryWithdrawal = null;
         var status:Object = Global.player.upgradeStatus;
         if(Boolean(status.isActive) && status.worldType == Global.worldManager.currentWorldType)
         {
            currentTime = GlobalEngine.getTimer() / 1000;
            expired = status.expires < currentTime;
            completed = status.numHelped == Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10);
            building = Global.world.getObjectById(status.buildingId) as StorageBuilding;
            if(completed)
            {
               if(building)
               {
                  building.upgrade(null);
               }
               Global.player.upgradeStatus.alreadyUpgraded = true;
               UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
            }
            else if(expired)
            {
               UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
            }
            else if(building is ChickenCoopBuilding && currentTime - status.lastPosted > Global.farmGameSettingsManager.getInt("storageUpgradeRepostTime",14400))
            {
               UI.displayStorageDialog(iw = new InventoryWithdrawal(null,"upgrade",false));
               iw.onRepostFeed(status.buildingId);
            }
         }
      }
   }
}

