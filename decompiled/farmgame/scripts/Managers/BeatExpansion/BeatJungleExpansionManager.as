package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatJungleExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatJungleExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xjm.swf";
      
      private static const FEATURE_NAME:String = "beatJungleExpansion";
      
      private static const LOC_PREFIX:String = "BeatJungleExpansion_";
      
      private static const ICON_NAME:String = "BeatJungleExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_jungle";
      
      public function BeatJungleExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatJungleExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatJungleExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatJungleExpansionManager(new SingletonEnforcer());
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
