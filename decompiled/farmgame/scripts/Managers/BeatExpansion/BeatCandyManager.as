package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatCandyManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatCandyManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/Candy/FV_BeatExpansion_xcw.swf";
      
      private static const FEATURE_NAME:String = "beatCandy";
      
      private static const LOC_PREFIX:String = "BeatCandy_";
      
      private static const ICON_NAME:String = "BeatCandy";
      
      private static const STAT_COUNTER_NAME:String = "beat_candy";
      
      public function BeatCandyManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatCandyManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatCandyManager
      {
         if(!s_instance)
         {
            s_instance = new BeatCandyManager(new SingletonEnforcer());
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
