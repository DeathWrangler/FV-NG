package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatturtleislandExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatturtleislandExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/turtleisland/FV_BeatExpansion_xti.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/turtleisland/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatturtleislandExpansion";
      
      private static const LOC_PREFIX:String = "BeatturtleislandExpansion_";
      
      private static const ICON_NAME:String = "BeatturtleislandExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_turtleisland";
      
      public function BeatturtleislandExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatturtleislandExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatturtleislandExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatturtleislandExpansionManager(new SingletonEnforcer());
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
