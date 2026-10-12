package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatKingdomManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatKingdomManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xmb.swf";
      
      private static const FEATURE_NAME:String = "beatKingdom";
      
      private static const LOC_PREFIX:String = "BeatKingdom_";
      
      private static const ICON_NAME:String = "BeatKingdom";
      
      private static const STAT_COUNTER_NAME:String = "beat_kingdom";
      
      public function BeatKingdomManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatKingdomManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatKingdomManager
      {
         if(!s_instance)
         {
            s_instance = new BeatKingdomManager(new SingletonEnforcer());
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
