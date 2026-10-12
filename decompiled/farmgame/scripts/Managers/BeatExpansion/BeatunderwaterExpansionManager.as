package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatunderwaterExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatunderwaterExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/underwater/FV_BeatExpansion_xuw.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/underwater/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatunderwaterExpansion";
      
      private static const LOC_PREFIX:String = "BeatunderwaterExpansion_";
      
      private static const ICON_NAME:String = "BeatunderwaterExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_underwater";
      
      public function BeatunderwaterExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatunderwaterExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatunderwaterExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatunderwaterExpansionManager(new SingletonEnforcer());
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
