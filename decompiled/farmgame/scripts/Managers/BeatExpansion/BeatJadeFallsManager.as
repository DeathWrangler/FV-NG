package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatJadeFallsManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatJadeFallsManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion.swf";
      
      private static const LOC_PREFIX:String = "BeatJadeFalls_";
      
      private static const ICON_NAME:String = "BeatJadeFalls";
      
      private static const FEATURE_NAME:String = "beatJadeFalls";
      
      private static const STAT_COUNTER_NAME:String = "beat_jade_falls";
      
      public function BeatJadeFallsManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatJadeFallsManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatJadeFallsManager
      {
         if(!s_instance)
         {
            s_instance = new BeatJadeFallsManager(new SingletonEnforcer());
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
