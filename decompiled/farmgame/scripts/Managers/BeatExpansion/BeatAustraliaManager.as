package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatAustraliaManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatAustraliaManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xau.swf";
      
      private static const FEATURE_NAME:String = "beatAustralia";
      
      private static const LOC_PREFIX:String = "BeatAustralia_";
      
      private static const ICON_NAME:String = "BeatAustralia";
      
      private static const STAT_COUNTER_NAME:String = "beat_australia";
      
      public function BeatAustraliaManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatAustraliaManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatAustraliaManager
      {
         if(!s_instance)
         {
            s_instance = new BeatAustraliaManager(new SingletonEnforcer());
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
