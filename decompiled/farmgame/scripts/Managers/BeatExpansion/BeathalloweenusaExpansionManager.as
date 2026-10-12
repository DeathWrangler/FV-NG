package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeathalloweenusaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeathalloweenusaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/halloweenusa/FV_BeatExpansion_xha.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/halloweenusa/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beathalloweenusaExpansion";
      
      private static const LOC_PREFIX:String = "BeathalloweenusaExpansion_";
      
      private static const ICON_NAME:String = "BeathalloweenusaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_halloweenusa";
      
      public function BeathalloweenusaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeathalloweenusaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeathalloweenusaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeathalloweenusaExpansionManager(new SingletonEnforcer());
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
