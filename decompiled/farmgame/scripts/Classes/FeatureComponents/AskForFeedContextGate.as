package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Managers.CaptureFeatureManager;
   
   public class AskForFeedContextGate extends ContextMenuGateHelper
   {
      
      public function AskForFeedContextGate(building:FeatureBuilding)
      {
         super(building);
      }
      
      override public function shouldDisplay() : Boolean
      {
         return CaptureFeatureManager.instance.initialized && CaptureFeatureManager.instance.canAskForTreats(CaptureFeatureManager.BIRD_FEATURE_NAME,CaptureFeatureManager.SOURCE_CONTEXT);
      }
   }
}

