package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatMapleExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatMapleExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/canada/FV_BeatExpansion_xcd.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/canada/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatcanadaExpansion";
      
      private static const LOC_PREFIX:String = "BeatMapleExpansion_";
      
      private static const ICON_NAME:String = "BeatMapleExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_canada";
      
      public function BeatMapleExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatMapleExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatMapleExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatMapleExpansionManager(new SingletonEnforcer());
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
