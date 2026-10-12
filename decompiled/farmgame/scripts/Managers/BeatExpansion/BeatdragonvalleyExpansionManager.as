package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatdragonvalleyExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatdragonvalleyExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/dragonvalley/FV_BeatExpansion_xdv.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/dragonvalley/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatdragonvalleyExpansion";
      
      private static const LOC_PREFIX:String = "BeatdragonvalleyExpansion_";
      
      private static const ICON_NAME:String = "BeatdragonvalleyExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_dragonvalley";
      
      public function BeatdragonvalleyExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatdragonvalleyExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatdragonvalleyExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatdragonvalleyExpansionManager(new SingletonEnforcer());
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
