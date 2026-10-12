package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatbrazilExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatbrazilExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/brazil/FV_BeatExpansion_xbr.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/brazil/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatbrazilExpansion";
      
      private static const LOC_PREFIX:String = "BeatbrazilExpansion_";
      
      private static const ICON_NAME:String = "BeatbrazilExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_brazil";
      
      public function BeatbrazilExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatbrazilExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatbrazilExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatbrazilExpansionManager(new SingletonEnforcer());
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
