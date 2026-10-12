package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatFantasyForestManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatFantasyForestManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FForest/FV_BeatExpansion_xff.swf";
      
      private static const FEATURE_NAME:String = "beatFforest";
      
      private static const LOC_PREFIX:String = "BeatFforest_";
      
      private static const ICON_NAME:String = "BeatFforest";
      
      private static const STAT_COUNTER_NAME:String = "beat_fforest";
      
      public function BeatFantasyForestManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatFantasyForestManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatFantasyForestManager
      {
         if(!s_instance)
         {
            s_instance = new BeatFantasyForestManager(new SingletonEnforcer());
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
