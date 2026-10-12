package Classes
{
   import Classes.Constants.Experiments;
   
   public class FixedConstructionBuilding extends ConstructionBuilding
   {
      
      private var m_debugMode:Boolean = false;
      
      public function FixedConstructionBuilding(buildingType:String = null)
      {
         super(buildingType);
         this.m_debugMode = this.isDebugMode();
      }
      
      private function get debugMode() : Boolean
      {
         return this.m_debugMode;
      }
      
      private function isDebugMode() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.initialized && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FIXED_CONSTRUCTION_BUILDING_DISABLE) > 0 && Config.DEBUG_MODE)
         {
            result = true;
         }
         return result;
      }
      
      override protected function canShowMoveMenuItem() : Boolean
      {
         var result:Boolean = false;
         if(this.debugMode)
         {
            result = super.canShowMoveMenuItem();
         }
         return result;
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         var result:Boolean = false;
         if(this.debugMode)
         {
            result = super.canShowSellMenuItem();
         }
         return result;
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         var result:Boolean = false;
         if(this.debugMode)
         {
            result = super.isDecoMoveSupported();
         }
         return result;
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = false;
         if(this.debugMode)
         {
            result = super.isSellable();
         }
         return result;
      }
      
      override public function isClearable() : Boolean
      {
         var result:Boolean = false;
         if(this.debugMode)
         {
            result = super.isClearable();
         }
         return result;
      }
   }
}

