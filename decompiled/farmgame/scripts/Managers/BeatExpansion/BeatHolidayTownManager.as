package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatHolidayTownManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatHolidayTownManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xhd.swf";
      
      private static const FEATURE_NAME:String = "beatHolidayTown";
      
      private static const LOC_PREFIX:String = "BeatHolidayTown_";
      
      private static const ICON_NAME:String = "BeatHolidayTown";
      
      private static const STAT_COUNTER_NAME:String = "beat_holiday_town";
      
      public function BeatHolidayTownManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatHolidayTownManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatHolidayTownManager
      {
         if(!s_instance)
         {
            s_instance = new BeatHolidayTownManager(new SingletonEnforcer());
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
