package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatcasablancaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatcasablancaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/casablanca/FV_BeatExpansion_xca.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/casablanca/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatcasablancaExpansion";
      
      private static const LOC_PREFIX:String = "BeatcasablancaExpansion_";
      
      private static const ICON_NAME:String = "BeatcasablancaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_casablanca";
      
      public function BeatcasablancaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatcasablancaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatcasablancaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatcasablancaExpansionManager(new SingletonEnforcer());
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
