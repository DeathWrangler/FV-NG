package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatTrailsExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatTrailsExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/madagascar/FV_BeatExpansion_xmt.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/madagascar/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatmadagascarExpansion";
      
      private static const LOC_PREFIX:String = "BeatTrailsExpansion_";
      
      private static const ICON_NAME:String = "BeatTrailsExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_madagascar";
      
      public function BeatTrailsExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatTrailsExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatTrailsExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatTrailsExpansionManager(new SingletonEnforcer());
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
