package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeattwentiesExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeattwentiesExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/twenties/FV_BeatExpansion_xrt.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/twenties/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beattwentiesExpansion";
      
      private static const LOC_PREFIX:String = "BeattwentiesExpansion_";
      
      private static const ICON_NAME:String = "BeattwentiesExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_twenties";
      
      public function BeattwentiesExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeattwentiesExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeattwentiesExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeattwentiesExpansionManager(new SingletonEnforcer());
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
