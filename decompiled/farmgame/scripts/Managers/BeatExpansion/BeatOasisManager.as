package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatOasisManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatOasisManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xoa.swf";
      
      private static const FEATURE_NAME:String = "beatOasis";
      
      private static const LOC_PREFIX:String = "BeatOasis_";
      
      private static const ICON_NAME:String = "BeatOasis";
      
      private static const STAT_COUNTER_NAME:String = "beat_oasis";
      
      public function BeatOasisManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatOasisManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatOasisManager
      {
         if(!s_instance)
         {
            s_instance = new BeatOasisManager(new SingletonEnforcer());
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
