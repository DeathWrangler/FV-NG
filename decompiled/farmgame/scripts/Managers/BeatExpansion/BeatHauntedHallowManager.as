package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatHauntedHallowManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatHauntedHallowManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xhw.swf";
      
      private static const LOC_PREFIX:String = "BeatHauntedHallow_";
      
      private static const ICON_NAME:String = "BeatHauntedHallow";
      
      private static const FEATURE_NAME:String = "beatHauntedHallow";
      
      private static const STAT_COUNTER_NAME:String = "beat_haunted_hallow";
      
      public function BeatHauntedHallowManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatHauntedHallowManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatHauntedHallowManager
      {
         if(!s_instance)
         {
            s_instance = new BeatHauntedHallowManager(new SingletonEnforcer());
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
