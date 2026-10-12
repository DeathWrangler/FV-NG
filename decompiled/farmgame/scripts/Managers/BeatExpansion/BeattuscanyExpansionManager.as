package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeattuscanyExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeattuscanyExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/tuscany/FV_BeatExpansion_xty.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/tuscany/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beattuscanyExpansion";
      
      private static const LOC_PREFIX:String = "BeattuscanyExpansion_";
      
      private static const ICON_NAME:String = "BeattuscanyExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_tuscany";
      
      public function BeattuscanyExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeattuscanyExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeattuscanyExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeattuscanyExpansionManager(new SingletonEnforcer());
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
