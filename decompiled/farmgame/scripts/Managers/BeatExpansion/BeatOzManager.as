package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatOzManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatOzManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xoz.swf";
      
      private static const FEATURE_NAME:String = "beatOz";
      
      private static const LOC_PREFIX:String = "BeatOz_";
      
      private static const ICON_NAME:String = "BeatOz";
      
      private static const STAT_COUNTER_NAME:String = "beat_oz";
      
      public function BeatOzManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatOzManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatOzManager
      {
         if(!s_instance)
         {
            s_instance = new BeatOzManager(new SingletonEnforcer());
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
