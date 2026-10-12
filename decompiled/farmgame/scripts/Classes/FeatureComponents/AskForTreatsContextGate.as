package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Managers.CaptureFeatureManager;
   
   public class AskForTreatsContextGate extends ContextMenuGateHelper
   {
      
      public function AskForTreatsContextGate(building:FeatureBuilding)
      {
         super(building);
      }
      
      override public function shouldDisplay() : Boolean
      {
         return CaptureFeatureManager.instance.initialized && CaptureFeatureManager.instance.canAskForTreats(CaptureFeatureManager.GOPHER_FEATURE_NAME,CaptureFeatureManager.SOURCE_CONTEXT);
      }
   }
}

