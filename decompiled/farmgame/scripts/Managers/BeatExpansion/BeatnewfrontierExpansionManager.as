package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatnewfrontierExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatnewfrontierExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/newfrontier/FV_BeatExpansion_xnf.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/newfrontier/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatnewfrontierExpansion";
      
      private static const LOC_PREFIX:String = "BeatnewfrontierExpansion_";
      
      private static const ICON_NAME:String = "BeatnewfrontierExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_newfrontier";
      
      public function BeatnewfrontierExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatnewfrontierExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatnewfrontierExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatnewfrontierExpansionManager(new SingletonEnforcer());
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
