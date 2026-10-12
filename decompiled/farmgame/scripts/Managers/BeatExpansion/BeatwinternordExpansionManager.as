package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatwinternordExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatwinternordExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/winternord/FV_BeatExpansion_xwx.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/winternord/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatwinternordExpansion";
      
      private static const LOC_PREFIX:String = "BeatwinternordExpansion_";
      
      private static const ICON_NAME:String = "BeatwinternordExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_winternord";
      
      public function BeatwinternordExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatwinternordExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatwinternordExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatwinternordExpansionManager(new SingletonEnforcer());
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
