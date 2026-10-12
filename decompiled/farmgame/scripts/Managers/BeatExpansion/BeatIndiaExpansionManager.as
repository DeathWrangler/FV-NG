package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatIndiaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatIndiaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xin.swf";
      
      private static const FEATURE_NAME:String = "beatIndiaExpansion";
      
      private static const LOC_PREFIX:String = "BeatIndiaExpansion_";
      
      private static const ICON_NAME:String = "BeatIndiaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_india";
      
      public function BeatIndiaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatIndiaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatIndiaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatIndiaExpansionManager(new SingletonEnforcer());
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
