package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatIrelandExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatIrelandExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/ireland/FV_BeatExpansion_xid.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/ireland/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatirelandExpansion";
      
      private static const LOC_PREFIX:String = "BeatIrelandExpansion_";
      
      private static const ICON_NAME:String = "BeatIrelandExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_ireland";
      
      public function BeatIrelandExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatIrelandExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatIrelandExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatIrelandExpansionManager(new SingletonEnforcer());
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
