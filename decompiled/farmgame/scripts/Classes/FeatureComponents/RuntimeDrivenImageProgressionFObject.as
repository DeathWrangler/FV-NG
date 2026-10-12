package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.RuntimeDrivenLootableFixedFeatureBuilding;
   
   public class RuntimeDrivenImageProgressionFObject extends DeferredImageProgressionFObject
   {
      
      public function RuntimeDrivenImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function doSetProgression(redraw:Boolean = false) : void
      {
         var level:int = 0;
         var runtimeKey:String = RuntimeDrivenLootableFixedFeatureBuilding.generateRuntimeKey(m_owner.featureName);
         if(Global.flashHotParams.hasOwnProperty(runtimeKey))
         {
            level = int(Global.flashHotParams[runtimeKey]);
         }
         m_owner.setOverlayOverride(level + 1,redraw);
         (m_owner as RuntimeDrivenLootableFixedFeatureBuilding).conditionallyUpgradeBuilding();
      }
   }
}

