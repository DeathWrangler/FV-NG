package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatxmasExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatxmasExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xch.swf";
      
      private static const FEATURE_NAME:String = "beatxmasExpansion";
      
      private static const LOC_PREFIX:String = "BeatxmasExpansion_";
      
      private static const ICON_NAME:String = "BeatxmasExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_xmas";
      
      public function BeatxmasExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatxmasExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatxmasExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatxmasExpansionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls));
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
