package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatTreasureTidesManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatTreasureTidesManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xsa.swf";
      
      private static const FEATURE_NAME:String = "beatTreasuretides";
      
      private static const LOC_PREFIX:String = "BeatTreasureTides_";
      
      private static const ICON_NAME:String = "BeatTreasureTides";
      
      private static const STAT_COUNTER_NAME:String = "beat_treasuretides";
      
      public function BeatTreasureTidesManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatTreasureTidesManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatTreasureTidesManager
      {
         if(!s_instance)
         {
            s_instance = new BeatTreasureTidesManager(new SingletonEnforcer());
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
