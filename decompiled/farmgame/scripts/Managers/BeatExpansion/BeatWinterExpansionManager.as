package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatWinterExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatWinterExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xwi.swf";
      
      private static const FEATURE_NAME:String = "beatWinterExpansion";
      
      private static const LOC_PREFIX:String = "BeatWinterExpansion_";
      
      private static const ICON_NAME:String = "BeatWinterExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_winter";
      
      public function BeatWinterExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatWinterExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatWinterExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatWinterExpansionManager(new SingletonEnforcer());
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
