package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatMediterraneanManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatMediterraneanManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xmd.swf";
      
      private static const FEATURE_NAME:String = "beatMediterranean";
      
      private static const LOC_PREFIX:String = "BeatMediterranean_";
      
      private static const ICON_NAME:String = "BeatMediterranean";
      
      private static const STAT_COUNTER_NAME:String = "beat_mediterranean";
      
      public function BeatMediterraneanManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatMediterraneanManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatMediterraneanManager
      {
         if(!s_instance)
         {
            s_instance = new BeatMediterraneanManager(new SingletonEnforcer());
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
