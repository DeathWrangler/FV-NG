package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatCoastalExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatCoastalExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/aloha/FV_BeatExpansion_xah.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/aloha/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatalohaExpansion";
      
      private static const LOC_PREFIX:String = "BeatCoastalExpansion_";
      
      private static const ICON_NAME:String = "BeatCoastalExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_aloha";
      
      public function BeatCoastalExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatCoastalExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatCoastalExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatCoastalExpansionManager(new SingletonEnforcer());
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
