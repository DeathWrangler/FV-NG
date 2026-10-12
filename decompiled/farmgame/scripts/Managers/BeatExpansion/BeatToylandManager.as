package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatToylandManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatToylandManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xtl.swf";
      
      private static const FEATURE_NAME:String = "beatToyland";
      
      private static const LOC_PREFIX:String = "BeatToyland_";
      
      private static const ICON_NAME:String = "BeatToyland";
      
      private static const STAT_COUNTER_NAME:String = "beat_toyland";
      
      public function BeatToylandManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatToylandManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatToylandManager
      {
         if(!s_instance)
         {
            s_instance = new BeatToylandManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls,FEATURE_NAME,1));
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
