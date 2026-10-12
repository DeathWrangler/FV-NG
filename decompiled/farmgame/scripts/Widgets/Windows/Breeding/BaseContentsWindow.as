package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Windows.FarmWindow;
   
   public class BaseContentsWindow extends FarmWindow
   {
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_skipCloseStat:Boolean = false;
      
      public function BaseContentsWindow(asset:String)
      {
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
      }
      
      protected function getLocalizedString(keySuffix:String, params:Object = null) : String
      {
         var localizationKey:String = this.m_building.bldgName + keySuffix;
         if(!ZLocUtils.hasString("Dialogs",localizationKey))
         {
            localizationKey = "AnimalBreedingGeneric" + keySuffix;
            if(!params)
            {
               params = {};
            }
            params.itemName = this.m_building.getFarmItem().friendlyTitle;
         }
         return ZLocUtils.t("Dialogs",localizationKey,params);
      }
      
      public function get building() : FeatureBuilding
      {
         return this.m_building;
      }
      
      public function set skipCloseStat(skip:Boolean) : void
      {
         this.m_skipCloseStat = skip;
      }
      
      override public function close() : void
      {
         if(!this.m_skipCloseStat)
         {
            FarmStatsManager.count("dialog",this.m_building.getItemName(),"X");
         }
         super.close();
      }
   }
}

