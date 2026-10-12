package Transactions
{
   import Managers.StorageExpandManager;
   import Managers.WorldManager;
   
   public class TWorldLoadAfterCache extends TWorldLoad
   {
      
      public function TWorldLoadAfterCache(worldType:String, manager:WorldManager, shouldCreateWorld:Boolean = false)
      {
         super(worldType,manager,shouldCreateWorld,false);
      }
      
      override public function perform() : void
      {
         GlobalEngine.info("Worlds","TWorldLoadAfterCache.perform [worldType=" + worldType + "]");
         signedCall("WorldService.postCachedWorldLoad",worldType,shouldCreateWorld,shouldFreezeFarm);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var otherWorldType:String = null;
         if(Boolean(result) && Boolean(result["user"]) && result.user["currentWorldType"] == Global.worldManager.currentWorldType)
         {
            GlobalEngine.info("Worlds","TWorldLoadAfterCache.onComplete [worldType=" + result.user.currentWorldType + "]");
            Global.player.initFeatureCredits(result.user.player.featureCredits);
            Global.player.setFeatureCreditsForWorld(result.user.currentWorldType);
            if(result["storageExpansionBuildingId"])
            {
               StorageExpandManager.getInstance().updateStorageExpansionData(result.storageExpansionBuildingId);
            }
            Global.worldManager.finalizeLoadFromCache(result);
         }
         else
         {
            otherWorldType = Boolean(result) && Boolean(result["user"]) && Boolean(result.user["currentWorldType"]) ? result.user["currentWorldType"] : "";
            Global.worldManager.trackWorldLoadAfterCacheMismatch(otherWorldType);
         }
      }
   }
}

