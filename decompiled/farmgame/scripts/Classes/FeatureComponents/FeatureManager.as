package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   
   public class FeatureManager
   {
      
      public static const EXPAND_FEATURE_NAME:String = "expand";
      
      public static const HARVEST_FEATURE_NAME:String = "harvester";
      
      public static const UPGRADE_FEATURE_NAME:String = "upgrader";
      
      public static const WITHER_FEATURE_NAME:String = "witherer";
      
      public static const NAMING_FEATURE_NAME:String = "nameOverride";
      
      public static const NEIGHBOR_ACTION_FEATURE_NAME:String = "neighborAction";
      
      public static const STORAGE_FEATURE_NAME:String = "storage";
      
      public static const RENDERING_FEATURE_NAME:String = "renderer";
      
      public static const CONTEXT_MENU_FEATURE_NAME:String = "contextMenu";
      
      public static const SLOTMACHINE_FEATURE_NAME:String = "slotmachine";
      
      public static const SLOTMACHINE2_FEATURE_NAME:String = "slotmachine2";
      
      public static const BUILDING_READY_ICON_FEATURE_NAME:String = "buildingReady";
      
      public static const ARROW_INDICATOR_MENU_FEATURE_NAME:String = "arrowIndicator";
      
      public static const TUTORIAL_MENU_FEATURE_NAME:String = "tutorial";
      
      public static const CONTAINEE_FEATURE_NAME:String = "containeeManager";
      
      public static const INSTANT_GROWN_FEATURE_NAME:String = "instantGrow";
      
      public static const TOOLTIP_TEXT_FEATURE_NAME:String = "tooltipText";
      
      public static const IMAGE_ADAPTER_FEATURE_NAME:String = "imageProgression";
      
      public static const INITIALIZER_FEATURE_NAME:String = "initializer";
      
      public static const GROWABLE_CONTEST_FEATURE_NAME:String = "Growable";
      
      public static const FLOWERSHACK_FEATURE_NAME:String = "flowershack";
      
      protected var m_owner:FeatureBuilding;
      
      protected var m_bundleData:Array = new Array();
      
      protected var m_feedAction:Array = new Array();
      
      protected var m_rewardObj:Object;
      
      public function FeatureManager(owner:FeatureBuilding)
      {
         super();
         this.m_owner = owner;
      }
      
      public function loadObject(data:Object) : void
      {
      }
      
      public function get owner() : FeatureBuilding
      {
         return this.m_owner;
      }
      
      public function set owner(owner:FeatureBuilding) : void
      {
         this.m_owner = owner;
      }
      
      public function replaceContent() : void
      {
      }
      
      public function onDetatch() : void
      {
      }
      
      public function onVisitClick() : void
      {
      }
   }
}

