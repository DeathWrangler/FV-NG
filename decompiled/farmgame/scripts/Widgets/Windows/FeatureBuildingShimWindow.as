package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Display.UI;
   import flash.utils.getDefinitionByName;
   
   public class FeatureBuildingShimWindow extends FarmWindow
   {
      
      public function FeatureBuildingShimWindow(building:FeatureBuilding)
      {
         super(null);
         this.launchRedirectWindow(building);
      }
      
      protected function launchRedirectWindow(building:FeatureBuilding) : void
      {
         var buildingName:String = building.getItemName();
         var dialogConfig:Object = Global.farmGameSettingsManager.getBuildingDialogConfig(buildingName);
         GlobalEngine.assert(Boolean(dialogConfig) && Boolean(dialogConfig.redirectClassName),"[FeatureBuidingShimWindow] redirectClassName was not found in dialog config.");
         var dialogClassName:String = dialogConfig.redirectClassName;
         var dialogClass:Class = getDefinitionByName(dialogClassName) as Class;
         var buildingDialog:FarmWindow = dialogConfig.cameFromBuilding ? new dialogClass(buildingName,"building") : new dialogClass();
         UI.displayPopup(buildingDialog,true,dialogClassName,true);
      }
      
      override public function show() : void
      {
         close();
      }
   }
}

