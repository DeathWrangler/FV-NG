package Classes.breeding
{
   import Classes.FeatureBuilding;
   
   public class BreedingFeatureState
   {
      
      public const MAX_NUM_TRAYS_POSSIBLE:int = 10;
      
      protected var m_featureName:String;
      
      protected var m_unlockedStates:Object;
      
      protected var m_genealogy:Array;
      
      protected var m_trays:Array;
      
      protected var m_projectDuration:Number;
      
      protected var m_upgradeUnlockedTrays:Object;
      
      private var m_pvpStat:String;
      
      public function BreedingFeatureState(featureName:String, unlockState:Object, genealogy:Array, upgradeUnlockedTrays:Object, projectDuration:Number = 259200, pvpStat:String = "")
      {
         super();
         this.m_featureName = featureName;
         this.m_trays = new Array(this.MAX_NUM_TRAYS_POSSIBLE);
         this.m_genealogy = genealogy;
         this.m_unlockedStates = unlockState;
         this.m_projectDuration = projectDuration;
         this.m_upgradeUnlockedTrays = upgradeUnlockedTrays;
         this.m_pvpStat = pvpStat;
      }
      
      public function addNewTray(trayIndex:int, trayInfo:Object) : BreedingTray
      {
         var newTray:BreedingTray = null;
         var result:BreedingTray = null;
         if(this.isTrayEmpty(trayIndex) == true && trayIndex < this.getNumUnlockedTrays())
         {
            newTray = new BreedingTray(trayInfo);
            this.m_trays[trayIndex] = newTray;
            result = this.m_trays[trayIndex];
         }
         return result;
      }
      
      public function getTrayState(trayIndex:int) : BreedingTray
      {
         var trayState:BreedingTray = null;
         if(this.isTrayEmpty(trayIndex) == false)
         {
            trayState = this.m_trays[trayIndex];
         }
         return trayState;
      }
      
      public function isTrayEmpty(trayIndex:int) : Boolean
      {
         return !(trayIndex < this.MAX_NUM_TRAYS_POSSIBLE && this.m_trays[trayIndex]);
      }
      
      public function getNumUnlockedTrays() : int
      {
         var featureObjects:Array = Global.world.getObjectsByName(this.m_featureName);
         var upgradeLevel:int = 0;
         if(featureObjects[0] is FeatureBuilding)
         {
            upgradeLevel = (featureObjects[0] as FeatureBuilding).storageLevel;
         }
         return this.m_upgradeUnlockedTrays[upgradeLevel];
      }
      
      public function getNumEmptyTrays() : int
      {
         return this.getNumUnlockedTrays() - this.m_trays.length;
      }
      
      public function timeRemaining(trayIndex:int) : Number
      {
         var bt:BreedingTray = this.getTrayState(trayIndex);
         var Endtime:Number = Number(bt.startTime) + this.m_projectDuration - 86400 * bt.getNumDaysReduced();
         return Endtime - GlobalEngine.serverTime / 1000;
      }
      
      public function clearTray(trayIndex:int) : void
      {
         this.m_trays[trayIndex] = null;
      }
      
      public function get genealogy() : Array
      {
         return this.m_genealogy;
      }
      
      public function get unlockedStates() : Array
      {
         return this.m_unlockedStates as Array;
      }
      
      public function get trays() : Array
      {
         return this.m_trays;
      }
      
      public function get pvpStat() : String
      {
         return this.m_pvpStat;
      }
   }
}

