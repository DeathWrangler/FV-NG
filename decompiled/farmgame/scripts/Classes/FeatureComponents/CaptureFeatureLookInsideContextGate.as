package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Managers.CaptureFeatureManager;
   
   public class CaptureFeatureLookInsideContextGate extends ContextMenuGateHelper
   {
      
      public function CaptureFeatureLookInsideContextGate(building:FeatureBuilding)
      {
         super(building);
      }
      
      override public function shouldDisplay() : Boolean
      {
         return CaptureFeatureManager.instance.initialized;
      }
   }
}

