package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatBloomExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatBloomExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/amsterdam/FV_BeatExpansion_xdm.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/amsterdam/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatamsterdamExpansion";
      
      private static const LOC_PREFIX:String = "BeatBloomExpansion_";
      
      private static const ICON_NAME:String = "BeatBloomExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_amsterdam";
      
      public function BeatBloomExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatBloomExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatBloomExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatBloomExpansionManager(new SingletonEnforcer());
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
