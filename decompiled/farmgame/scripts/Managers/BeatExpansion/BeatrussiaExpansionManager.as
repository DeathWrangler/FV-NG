package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatrussiaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatrussiaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/russia/FV_BeatExpansion_xru.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/russia/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatrussiaExpansion_a";
      
      private static const LOC_PREFIX:String = "BeatrussiaExpansion_";
      
      private static const ICON_NAME:String = "BeatrussiaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_russia";
      
      public function BeatrussiaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatrussiaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatrussiaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatrussiaExpansionManager(new SingletonEnforcer());
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
