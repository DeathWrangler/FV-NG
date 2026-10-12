package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatSecretExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatSecretExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/santavillage/FV_BeatExpansion_xws.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/santavillage/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatsantavillageExpansion";
      
      private static const LOC_PREFIX:String = "BeatSecretExpansion_";
      
      private static const ICON_NAME:String = "BeatSecretExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_santavillage";
      
      public function BeatSecretExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatSecretExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatSecretExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatSecretExpansionManager(new SingletonEnforcer());
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
