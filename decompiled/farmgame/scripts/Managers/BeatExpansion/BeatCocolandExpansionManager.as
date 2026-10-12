package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatCocolandExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatCocolandExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/cocoland/FV_BeatExpansion_xcl.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/cocoland/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatcocolandExpansion";
      
      private static const LOC_PREFIX:String = "BeatCocolandExpansion_";
      
      private static const ICON_NAME:String = "BeatCocolandExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_cocoland";
      
      public function BeatCocolandExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatCocolandExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatCocolandExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatCocolandExpansionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      override public function displayUI() : void
      {
         UI.displayPopup(new BeatExpansionWindow(DIALOG_ASSET,this,getTaskData(),m_rewardImageUrls,null,-1,DIALOG_BG_ASSET));
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
