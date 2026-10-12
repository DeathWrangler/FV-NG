package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatAfricaManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatAfricaManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xaf.swf";
      
      private static const FEATURE_NAME:String = "beatAfrica";
      
      private static const LOC_PREFIX:String = "BeatAfrica_";
      
      private static const ICON_NAME:String = "BeatAfrica";
      
      private static const STAT_COUNTER_NAME:String = "beat_africa";
      
      public function BeatAfricaManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatAfricaManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatAfricaManager
      {
         if(!s_instance)
         {
            s_instance = new BeatAfricaManager(new SingletonEnforcer());
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
