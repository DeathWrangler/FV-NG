package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatcaribbeanExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatcaribbeanExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/caribbean/FV_BeatExpansion_xcb.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/caribbean/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatcaribbeanExpansion";
      
      private static const LOC_PREFIX:String = "BeatcaribbeanExpansion_";
      
      private static const ICON_NAME:String = "BeatcaribbeanExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_caribbean";
      
      public function BeatcaribbeanExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatcaribbeanExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatcaribbeanExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatcaribbeanExpansionManager(new SingletonEnforcer());
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
