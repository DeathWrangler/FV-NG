package Classes.FeatureComponents
{
   import Classes.Building;
   import Classes.FeatureBuilding;
   
   public class CraftingSiloIndicatorFManager extends ArrowIndicatorFManager implements IStateIndicatorComponent
   {
      
      private static const INDICATOR_X_OFFSET:Number = -7;
      
      private static const INDICATOR_Y_OFFSET:Number = 25;
      
      private static const BACKOFF_FEATURE_NAME_BASE:String = "CraftingSiloIndicator";
      
      private static const FINAL_BACKOFF_INTERVAL:int = 5;
      
      public function CraftingSiloIndicatorFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override protected function getHorizontalOffset() : Number
      {
         return INDICATOR_X_OFFSET;
      }
      
      override protected function getVerticalOffset() : Number
      {
         return INDICATOR_Y_OFFSET;
      }
      
      override public function onClick() : void
      {
         super.onClick();
         m_owner.displayStorageDialog();
         Global.player.resetBackoffInterval(this.getBackoffFeatureName());
      }
      
      private function getBackoffFeatureName() : String
      {
         return BACKOFF_FEATURE_NAME_BASE + (this.m_owner ? String((this.m_owner as FeatureBuilding).storageLevel) : "");
      }
      
      override public function show(state:String = "default") : void
      {
         var backoffFeatureName:String = null;
         var ownerBuilding:Building = this.m_owner as FeatureBuilding;
         if(ownerBuilding.isBuilt() && !owner.hasReachedMaxExpansionLevel())
         {
            backoffFeatureName = this.getBackoffFeatureName();
            if(Global.player.canShowFeatureWithBackoff(backoffFeatureName,FINAL_BACKOFF_INTERVAL))
            {
               Global.player.incrementBackoffInterval(backoffFeatureName);
               super.show(state);
            }
         }
      }
   }
}

