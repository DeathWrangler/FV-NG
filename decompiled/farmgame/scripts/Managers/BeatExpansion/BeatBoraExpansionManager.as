package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatBoraExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatBoraExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/borabora/FV_BeatExpansion_xbb.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/borabora/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatboraboraExpansion";
      
      private static const LOC_PREFIX:String = "BeatBoraExpansion_";
      
      private static const ICON_NAME:String = "BeatBoraExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_borabora";
      
      public function BeatBoraExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatBoraExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatBoraExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatBoraExpansionManager(new SingletonEnforcer());
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
