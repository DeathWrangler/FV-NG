package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatStorybookManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatStorybookManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xsb.swf";
      
      private static const FEATURE_NAME:String = "beatStorybook";
      
      private static const LOC_PREFIX:String = "BeatStorybook_";
      
      private static const ICON_NAME:String = "BeatStorybook";
      
      private static const STAT_COUNTER_NAME:String = "beat_storybook";
      
      public function BeatStorybookManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatStorybookManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatStorybookManager
      {
         if(!s_instance)
         {
            s_instance = new BeatStorybookManager(new SingletonEnforcer());
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
