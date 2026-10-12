package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Managers.FeatureCraftingManager;
   
   public class FeatureCraftingBuildingShimWindow extends FeatureBuildingShimWindow
   {
      
      public function FeatureCraftingBuildingShimWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function launchRedirectWindow(building:FeatureBuilding) : void
      {
         FeatureCraftingManager.instance.showBuildingUI(building.bldgName);
      }
   }
}

