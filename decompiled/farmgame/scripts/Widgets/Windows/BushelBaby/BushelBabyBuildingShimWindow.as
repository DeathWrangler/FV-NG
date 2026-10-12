package Widgets.Windows.BushelBaby
{
   import Classes.FeatureBuilding;
   import Managers.BushelBabyManager;
   import Widgets.Windows.FeatureBuildingShimWindow;
   
   public class BushelBabyBuildingShimWindow extends FeatureBuildingShimWindow
   {
      
      public function BushelBabyBuildingShimWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function launchRedirectWindow(building:FeatureBuilding) : void
      {
         BushelBabyManager.instance.showBuildingUI(building.getResourceItemCode());
      }
   }
}

