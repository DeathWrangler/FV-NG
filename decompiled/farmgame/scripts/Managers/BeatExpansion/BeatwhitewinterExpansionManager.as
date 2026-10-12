package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatwhitewinterExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatwhitewinterExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/whitewinter/FV_BeatExpansion_xfw.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/whitewinter/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatwhitewinterExpansion";
      
      private static const LOC_PREFIX:String = "BeatwhitewinterExpansion_";
      
      private static const ICON_NAME:String = "BeatwhitewinterExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_whitewinter";
      
      public function BeatwhitewinterExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatwhitewinterExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatwhitewinterExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatwhitewinterExpansionManager(new SingletonEnforcer());
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
