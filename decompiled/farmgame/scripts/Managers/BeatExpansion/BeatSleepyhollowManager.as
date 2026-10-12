package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatSleepyhollowManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatSleepyhollowManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xsh.swf";
      
      private static const FEATURE_NAME:String = "beatSleepyhollow";
      
      private static const LOC_PREFIX:String = "BeatSleepyhollow_";
      
      private static const ICON_NAME:String = "BeatSleepyhollow";
      
      private static const STAT_COUNTER_NAME:String = "beat_sleepyhollow";
      
      public function BeatSleepyhollowManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatSleepyhollowManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatSleepyhollowManager
      {
         if(!s_instance)
         {
            s_instance = new BeatSleepyhollowManager(new SingletonEnforcer());
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
