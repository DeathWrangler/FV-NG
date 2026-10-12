package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatRainForestManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatRainForestManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xrf.swf";
      
      private static const FEATURE_NAME:String = "beatRainForest";
      
      private static const LOC_PREFIX:String = "BeatRainForest_";
      
      private static const ICON_NAME:String = "BeatRainForest";
      
      private static const STAT_COUNTER_NAME:String = "beat_rainforest";
      
      public function BeatRainForestManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatRainForestManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatRainForestManager
      {
         if(!s_instance)
         {
            s_instance = new BeatRainForestManager(new SingletonEnforcer());
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
