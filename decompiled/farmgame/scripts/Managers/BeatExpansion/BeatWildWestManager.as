package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatWildWestManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatWildWestManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xwa.swf";
      
      private static const FEATURE_NAME:String = "beatWildWest";
      
      private static const LOC_PREFIX:String = "BeatWildWest_";
      
      private static const ICON_NAME:String = "BeatWildWest";
      
      private static const STAT_COUNTER_NAME:String = "beat_wildwest";
      
      public function BeatWildWestManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatWildWestManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatWildWestManager
      {
         if(!s_instance)
         {
            s_instance = new BeatWildWestManager(new SingletonEnforcer());
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
