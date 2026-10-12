package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatTransylvaniaManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatTransylvaniaManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xtr.swf";
      
      private static const FEATURE_NAME:String = "beatTransylvania";
      
      private static const LOC_PREFIX:String = "BeatTransylvania_";
      
      private static const ICON_NAME:String = "BeatTransylvania";
      
      private static const STAT_COUNTER_NAME:String = "beat_transylvania";
      
      public function BeatTransylvaniaManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatTransylvaniaManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatTransylvaniaManager
      {
         if(!s_instance)
         {
            s_instance = new BeatTransylvaniaManager(new SingletonEnforcer());
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
