package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatlimboExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatlimboExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_BeatExpansion_xbo.swf";
      
      private static const FEATURE_NAME:String = "beatlimboExpansion";
      
      private static const LOC_PREFIX:String = "BeatlimboExpansion_";
      
      private static const ICON_NAME:String = "BeatlimboExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_limbo";
      
      public function BeatlimboExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatlimboExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatlimboExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatlimboExpansionManager(new SingletonEnforcer());
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
