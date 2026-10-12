package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatmidwestExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatmidwestExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/midwest/FV_BeatExpansion_xhh.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/midwest/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatmidwestExpansion";
      
      private static const LOC_PREFIX:String = "BeatmidwestExpansion_";
      
      private static const ICON_NAME:String = "BeatmidwestExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_midwest";
      
      public function BeatmidwestExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatmidwestExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatmidwestExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatmidwestExpansionManager(new SingletonEnforcer());
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
