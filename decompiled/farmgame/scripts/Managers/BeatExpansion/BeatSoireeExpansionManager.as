package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatSoireeExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatSoireeExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/pumpkin/FV_BeatExpansion_xpu.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/pumpkin/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatpumpkinExpansion";
      
      private static const LOC_PREFIX:String = "BeatSoireeExpansion_";
      
      private static const ICON_NAME:String = "BeatSoireeExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_pumpkin";
      
      public function BeatSoireeExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatSoireeExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatSoireeExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatSoireeExpansionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls,null,-1,DIALOG_BG_ASSET));
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
