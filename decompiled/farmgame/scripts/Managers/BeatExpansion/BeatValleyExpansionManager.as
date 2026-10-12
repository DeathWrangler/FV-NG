package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatValleyExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatValleyExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/farmfest/FV_BeatExpansion_xfs.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/farmfest/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatfarmfestExpansion";
      
      private static const LOC_PREFIX:String = "BeatValleyExpansion_";
      
      private static const ICON_NAME:String = "BeatValleyExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_farmfest";
      
      public function BeatValleyExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatValleyExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatValleyExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatValleyExpansionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls,null,-1,DIALOG_BG_ASSET));
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
