package Classes
{
   import Classes.Idle.FarmDynamicDialogIdleTask;
   import Managers.FarmStatsManager;
   
   public class FishermansCoveBuilding extends FixedFeatureBuilding
   {
      
      public static const EXPERIMENT_REPROMPT_KEY:String = "fv_fishermanscove_reprompt";
      
      public static const HARVEST_ARROW_X_POSITION:int = 922;
      
      public static const HARVEST_ARROW_Y_POSITION:int = -40;
      
      private var m_isAutoPop:Boolean = false;
      
      public function FishermansCoveBuilding(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         super.onHarvestComplete(result);
         if(Global.experimentManager.getExperimentVariant(EXPERIMENT_REPROMPT_KEY) == 1 && !hasReachedMaxExpansionLevel())
         {
            new FarmDynamicDialogIdleTask(null,2000,this.displayStorageDialog).submit();
            this.m_isAutoPop = true;
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         super.displayStorageDialog(defaultAction);
         var counterPhylum:String = "";
         if(this.m_isAutoPop)
         {
            counterPhylum = "open_on_harvest";
            this.m_isAutoPop = false;
         }
         FarmStatsManager.count("constructible_cove","open_ui",counterPhylum);
      }
      
      override protected function setArrowPosition() : void
      {
         m_arrow.x = HARVEST_ARROW_X_POSITION;
         m_arrow.y = HARVEST_ARROW_Y_POSITION;
      }
   }
}

