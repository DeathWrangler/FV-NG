package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatAvalonManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatAvalonManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xma.swf";
      
      private static const FEATURE_NAME:String = "beatAvalon";
      
      private static const LOC_PREFIX:String = "BeatAvalon_";
      
      private static const ICON_NAME:String = "BeatAvalon";
      
      private static const STAT_COUNTER_NAME:String = "beat_avalon";
      
      public function BeatAvalonManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatAvalonManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatAvalonManager
      {
         if(!s_instance)
         {
            s_instance = new BeatAvalonManager(new SingletonEnforcer());
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
