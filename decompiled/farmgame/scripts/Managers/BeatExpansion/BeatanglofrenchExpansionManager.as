package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatanglofrenchExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatanglofrenchExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/anglofrench/FV_BeatExpansion_xfe.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/anglofrench/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatanglofrenchExpansion";
      
      private static const LOC_PREFIX:String = "BeatanglofrenchExpansion_";
      
      private static const ICON_NAME:String = "BeatanglofrenchExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_anglofrench";
      
      public function BeatanglofrenchExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatanglofrenchExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatanglofrenchExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatanglofrenchExpansionManager(new SingletonEnforcer());
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
