package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Managers.FeatureCraftingManager;
   import flash.events.Event;
   
   public class FeatureCraftingImageProgressionFObject extends ImageProgressionFObject
   {
      
      public function FeatureCraftingImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
         FeatureCraftingManager.instance.addEventListener(FeatureCraftingManager.EVENT_INIT,this.onInit,false,0,true);
         FeatureCraftingManager.instance.addEventListener(FeatureCraftingManager.EVENT_LEVEL_CHANGE,this.onLevelChange,false,0,true);
      }
      
      override public function doSetProgression(redraw:Boolean = false) : void
      {
         var level:int = this.getProgressionLevel();
         m_owner.setOverlayOverride(level + 1,redraw);
      }
      
      override protected function getProgressionCount() : int
      {
         var result:int = 0;
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystemForBuilding(m_owner.bldgName);
         if(system)
         {
            result = system.getPointLevel();
         }
         return result;
      }
      
      private function onInit(event:Event) : void
      {
         this.doSetProgression(true);
      }
      
      private function onLevelChange(event:Event) : void
      {
         this.doSetProgression(true);
      }
      
      override public function onDetatch() : void
      {
         FeatureCraftingManager.instance.removeEventListener(FeatureCraftingManager.EVENT_INIT,this.onInit,false);
         FeatureCraftingManager.instance.removeEventListener(FeatureCraftingManager.EVENT_LEVEL_CHANGE,this.onLevelChange,false);
      }
   }
}

