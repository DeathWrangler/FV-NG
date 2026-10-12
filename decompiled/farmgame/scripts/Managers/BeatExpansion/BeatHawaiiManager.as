package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatHawaiiManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatHawaiiManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xhi.swf";
      
      private static const FEATURE_NAME:String = "beatHawaii";
      
      private static const LOC_PREFIX:String = "BeatHawaii_";
      
      private static const ICON_NAME:String = "BeatHawaii";
      
      private static const STAT_COUNTER_NAME:String = "beat_hawaii";
      
      public function BeatHawaiiManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatHawaiiManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatHawaiiManager
      {
         if(!s_instance)
         {
            s_instance = new BeatHawaiiManager(new SingletonEnforcer());
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
