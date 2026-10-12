package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeathalloweenmadExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeathalloweenmadExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/halloweenmad/FV_BeatExpansion_xhx.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/halloweenmad/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beathalloweenmadExpansion";
      
      private static const LOC_PREFIX:String = "BeathalloweenmadExpansion_";
      
      private static const ICON_NAME:String = "BeathalloweenmadExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_halloweenmad";
      
      public function BeathalloweenmadExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeathalloweenmadExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeathalloweenmadExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeathalloweenmadExpansionManager(new SingletonEnforcer());
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
