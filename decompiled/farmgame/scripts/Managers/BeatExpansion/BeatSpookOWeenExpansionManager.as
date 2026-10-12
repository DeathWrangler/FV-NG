package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatSpookOWeenExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatSpookOWeenExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/spooky/FV_BeatExpansion_xhf.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/spooky/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatspookyExpansion";
      
      private static const LOC_PREFIX:String = "BeatSpookOWeenExpansion_";
      
      private static const ICON_NAME:String = "BeatSpookOWeenExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_spooky";
      
      public function BeatSpookOWeenExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatSpookOWeenExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatSpookOWeenExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatSpookOWeenExpansionManager(new SingletonEnforcer());
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
