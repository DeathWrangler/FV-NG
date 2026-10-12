package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatisraelExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatisraelExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/israel/FV_BeatExpansion_xis.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/israel/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatisraelExpansion";
      
      private static const LOC_PREFIX:String = "BeatisraelExpansion_";
      
      private static const ICON_NAME:String = "BeatisraelExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_israel";
      
      public function BeatisraelExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatisraelExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatisraelExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatisraelExpansionManager(new SingletonEnforcer());
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
