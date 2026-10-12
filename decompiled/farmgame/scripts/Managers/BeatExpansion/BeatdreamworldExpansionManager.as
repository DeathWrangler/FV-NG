package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatdreamworldExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatdreamworldExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/dreamworld/FV_BeatExpansion_xdw.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/dreamworld/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatdreamworldExpansion";
      
      private static const LOC_PREFIX:String = "BeatdreamworldExpansion_";
      
      private static const ICON_NAME:String = "BeatdreamworldExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_dreamworld";
      
      public function BeatdreamworldExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatdreamworldExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatdreamworldExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatdreamworldExpansionManager(new SingletonEnforcer());
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
