package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Managers.FarmGameSettingsManager;
   import Widgets.Windows.FlowerShackWindow;
   import flash.utils.getDefinitionByName;
   
   public class FlowerShackFManager extends FeatureManager
   {
      
      private var m_dialogClassName:String;
      
      protected var m_dialogAssetPath:String;
      
      protected var m_window:FlowerShackWindow;
      
      public function FlowerShackFManager(owner:FeatureBuilding)
      {
         var ownerFarmItem:FarmItem = null;
         var featureData:BaseDataSource = null;
         var dialogData:BaseDataSource = null;
         var featureXML:XML = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            ownerFarmItem = m_owner.getFarmItem();
            featureData = ownerFarmItem.getFeatureDataByName(FeatureManager.FLOWERSHACK_FEATURE_NAME);
            if(featureData)
            {
               dialogData = featureData.getData("dialog");
               this.m_dialogClassName = dialogData.getString("className");
               this.m_dialogAssetPath = dialogData.getString("path");
            }
         }
         else
         {
            featureXML = m_owner.currentFeatureXML;
            this.m_dialogClassName = String(featureXML.dialog.@className);
            this.m_dialogAssetPath = String(featureXML.dialog.@path);
         }
      }
      
      public function displayWindow() : void
      {
         if(this.m_window)
         {
            this.m_window = null;
         }
         var className:Class = getDefinitionByName(this.m_dialogClassName) as Class;
         this.m_window = new className();
         UI.displayPopup(this.m_window);
      }
      
      public function onWindowClose() : void
      {
         if(this.m_window != null)
         {
            this.m_window = null;
         }
      }
   }
}

