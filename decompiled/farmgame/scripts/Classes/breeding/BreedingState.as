package Classes.breeding
{
   public class BreedingState
   {
      
      private var m_initialized:Boolean = false;
      
      protected var m_breedingFeatures:Object;
      
      public function BreedingState()
      {
         super();
         this.m_breedingFeatures = new Object();
      }
      
      public function initBreedingStateFromInitUser(breedingStateResult:Object) : void
      {
         var breedFeatureData:Object = null;
         var bfs:BreedingFeatureState = null;
         var trayDataIndex:String = null;
         for each(breedFeatureData in breedingStateResult)
         {
            bfs = this.createNewBreedingFeatureState(breedFeatureData.featureName,breedFeatureData.unlockStates,breedFeatureData.genealogy,breedFeatureData.upgradeUnlockedTrays,breedFeatureData.breedingDuration,breedFeatureData.pvpStat);
            for(trayDataIndex in breedFeatureData.trays)
            {
               breedFeatureData.trays[trayDataIndex].tray.itemCode = breedFeatureData.trays[trayDataIndex].trayResult;
               bfs.addNewTray(int(trayDataIndex),breedFeatureData.trays[trayDataIndex].tray);
            }
         }
      }
      
      public function getBreedingFeatureState(featureName:String) : BreedingFeatureState
      {
         var featureState:BreedingFeatureState = null;
         if(this.m_breedingFeatures[featureName])
         {
            featureState = this.m_breedingFeatures[featureName];
         }
         return featureState;
      }
      
      public function createNewBreedingFeatureState(featureName:String, unlockState:Object, genealogy:Array, upgradeUnlockedTrays:Object, projectDuration:Number = 259200, pvpStat:String = "") : BreedingFeatureState
      {
         var featureState:BreedingFeatureState = new BreedingFeatureState(featureName,unlockState,genealogy,upgradeUnlockedTrays,projectDuration,pvpStat);
         this.m_breedingFeatures[featureName] = featureState;
         return featureState;
      }
   }
}

