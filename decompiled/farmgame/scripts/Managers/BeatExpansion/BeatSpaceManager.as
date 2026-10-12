package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatSpaceManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatSpaceManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/Space/FV_BeatExpansion_xsp.swf";
      
      private static const FEATURE_NAME:String = "beatSpace";
      
      private static const LOC_PREFIX:String = "BeatSpace_";
      
      private static const ICON_NAME:String = "BeatSpace";
      
      private static const STAT_COUNTER_NAME:String = "beat_space";
      
      public function BeatSpaceManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatSpaceManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatSpaceManager
      {
         if(!s_instance)
         {
            s_instance = new BeatSpaceManager(new SingletonEnforcer());
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
