package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatEnchantedGlenManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatEnchantedGlenManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xeg.swf";
      
      private static const FEATURE_NAME:String = "beatEnchantedGlen";
      
      private static const LOC_PREFIX:String = "BeatEnchantedGlen_";
      
      private static const ICON_NAME:String = "BeatEnchantedGlen";
      
      private static const STAT_COUNTER_NAME:String = "beat_enchanted_glen";
      
      public function BeatEnchantedGlenManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatEnchantedGlenManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatEnchantedGlenManager
      {
         if(!s_instance)
         {
            s_instance = new BeatEnchantedGlenManager(new SingletonEnforcer());
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
