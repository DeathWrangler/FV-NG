package Classes
{
   import Classes.Constants.Experiments;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingManager;
   
   public class DragonBreedingFeatureBuilding extends FeatureBuilding
   {
      
      private const FEATURE_NAME:String = "dragon_pen_finished";
      
      public function DragonBreedingFeatureBuilding(itemName:String = null)
      {
         super(itemName);
         if(this.isHarvestable())
         {
            setState(FeatureBuilding.STATE_RIPE);
         }
      }
      
      override public function onClick() : void
      {
         if(this.isHarvestable())
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_DRAGON_BREEDING) > Experiments.DRAGON_VARIANT_1)
            {
               this.displayStorageDialog();
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      override protected function determineState(delta:Number) : void
      {
         if(this.isHarvestable())
         {
            setState(FeatureBuilding.STATE_RIPE);
         }
         else
         {
            setState(FeatureBuilding.STATE_BARE);
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var tooltip:String = "";
         if(this.isHarvestable())
         {
            tooltip = ZLocUtils.t("FarmGame","AnimalBuilding_ready",{
               "item":m_item.friendlyTitle,
               "capacityStr":""
            });
         }
         else
         {
            tooltip = m_item.friendlyTitle;
         }
         setToolTip(tooltip);
         updateToolTipPosition();
      }
      
      override public function isHarvestable() : Boolean
      {
         var i:int = 0;
         var result:Boolean = false;
         var dbskillState:DragonBreedingSkillState = DragonBreedingManager.getInstance(this.FEATURE_NAME).getBreedingSkillState();
         if(dbskillState)
         {
            if(dbskillState.level <= 1 && dbskillState.xp <= 0)
            {
               result = false;
            }
            else
            {
               i = 0;
               while(i < dbskillState.unlockedSuites)
               {
                  if(DragonBreedingManager.getInstance(this.FEATURE_NAME).isAnyBreedingComplete() || DragonBreedingManager.getHatcheryManager(this.FEATURE_NAME).canGetMystree(i.toString()))
                  {
                     result = true;
                  }
                  i++;
               }
            }
         }
         return result;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         this.displayStorageDialog();
         setState(FeatureBuilding.STATE_BARE);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         DragonBreedingManager.getInstance(this.FEATURE_NAME).openDragonBreedingUI();
      }
      
      override protected function getSellDisplayMessage() : String
      {
         return ZLocUtils.t("FarmGame","sell_eyrie");
      }
   }
}

