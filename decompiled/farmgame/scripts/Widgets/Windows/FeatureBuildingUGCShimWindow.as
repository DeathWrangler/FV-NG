package Widgets.Windows
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.IUGCItem;
   import Display.UI;
   import Managers.UGCDecoManager;
   import flash.utils.getDefinitionByName;
   
   public class FeatureBuildingUGCShimWindow extends FeatureBuildingShimWindow
   {
      
      public function FeatureBuildingUGCShimWindow(building:FeatureBuilding)
      {
         super(building);
      }
      
      override protected function launchRedirectWindow(building:FeatureBuilding) : void
      {
         var gameSettingsFeatureName:String = building.getItem().gameSettingsFeatureName;
         if(gameSettingsFeatureName == null || gameSettingsFeatureName == "")
         {
            gameSettingsFeatureName = UGCDecoManager.DEFAULT_FEATURE_NAME;
         }
         var ugcItem:IUGCItem = null;
         var dialogConfig:Object = Global.farmGameSettingsManager.getBuildingDialogConfig(building.getItemName());
         GlobalEngine.assert(Boolean(dialogConfig) && Boolean(dialogConfig.redirectClassName),"[FeatureBuidingShimWindow] redirectClassName was not found in dialog config.");
         var dialogClassName:String = dialogConfig.redirectClassName;
         var dialogClass:Class = getDefinitionByName(dialogClassName) as Class;
         var buildingDialog:FarmWindow = new dialogClass(ugcItem,null,gameSettingsFeatureName);
         UI.displayPopup(buildingDialog,true,dialogClassName,true);
      }
   }
}

