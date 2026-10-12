package Classes
{
   import Classes.Constants.Experiments;
   
   public class FixedFeatureBuilding extends FeatureBuilding
   {
      
      private var m_debugMode:Boolean = false;
      
      public function FixedFeatureBuilding(itemName:String = null)
      {
         super(itemName);
         this.m_debugMode = this.isDebugMode();
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
         if(this.m_debugMode)
         {
            result = super.canShowMoveMenuItem();
         }
         return result;
      }
      
      override protected function canShowSellMenuItem() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.canShowSellMenuItem();
         }
         return result;
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.isDecoMoveSupported();
         }
         return result;
      }
      
      override public function isSellable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.isSellable();
         }
         return result;
      }
      
      override public function isClearable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.isClearable();
         }
         return result;
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.canShowStoreMenuItem();
         }
         return result;
      }
      
      override public function isStorable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.isStorable();
         }
         return result;
      }
      
      override public function isMovable() : Boolean
      {
         var result:Boolean = false;
         if(this.m_debugMode)
         {
            result = super.isMovable();
         }
         return result;
      }
   }
}

