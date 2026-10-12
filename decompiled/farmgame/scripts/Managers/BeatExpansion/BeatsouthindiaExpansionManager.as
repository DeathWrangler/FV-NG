package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatsouthindiaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatsouthindiaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/southindia/FV_BeatExpansion_xbl.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/southindia/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatsouthindiaExpansion";
      
      private static const LOC_PREFIX:String = "BeatsouthindiaExpansion_";
      
      private static const ICON_NAME:String = "BeatsouthindiaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_southindia";
      
      public function BeatsouthindiaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatsouthindiaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatsouthindiaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatsouthindiaExpansionManager(new SingletonEnforcer());
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
