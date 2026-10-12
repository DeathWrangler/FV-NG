package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatAtlantisManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatAtlantisManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xal.swf";
      
      private static const FEATURE_NAME:String = "beatAtlantis";
      
      private static const LOC_PREFIX:String = "BeatAtlantis_";
      
      private static const ICON_NAME:String = "BeatAtlantis";
      
      private static const STAT_COUNTER_NAME:String = "beat_atlantis";
      
      public function BeatAtlantisManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatAtlantisManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatAtlantisManager
      {
         if(!s_instance)
         {
            s_instance = new BeatAtlantisManager(new SingletonEnforcer());
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
