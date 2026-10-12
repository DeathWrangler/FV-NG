package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatHolidayLightsManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatHolidayLightsManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xhl.swf";
      
      private static const FEATURE_NAME:String = "beatHlights";
      
      private static const LOC_PREFIX:String = "BeatHlights_";
      
      private static const ICON_NAME:String = "BeatHlights";
      
      private static const STAT_COUNTER_NAME:String = "beat_hlights";
      
      public function BeatHolidayLightsManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatHolidayLightsManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatHolidayLightsManager
      {
         if(!s_instance)
         {
            s_instance = new BeatHolidayLightsManager(new SingletonEnforcer());
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
