package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatmountExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatmountExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xmo.swf";
      
      private static const FEATURE_NAME:String = "beatmountExpansion";
      
      private static const LOC_PREFIX:String = "BeatmountExpansion_";
      
      private static const ICON_NAME:String = "BeatmountExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_mount";
      
      public function BeatmountExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatmountExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatmountExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatmountExpansionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls));
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
