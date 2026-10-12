package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Managers.CaptureFeatureManager;
   
   public class GopherImageProgressionFObject extends DeferredImageProgressionFObject
   {
      
      public function GopherImageProgressionFObject(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function doSetProgression(redraw:Boolean = false) : void
      {
         var level:int = CaptureFeatureManager.instance.getCurrentBuildLevel(m_owner.featureName);
         m_owner.setOverlayOverride(level + 1,redraw);
      }
   }
}

