package Managers.BeatExpansion
{
   import Display.UI;
   import Widgets.Windows.BeatExpansion.BeatExpansionWindow;
   
   public class BeatAlaskaExpansionManager extends BeatExpansionBaseManager
   {
      
      private static var s_instance:BeatAlaskaExpansionManager;
      
      private static const DIALOG_ASSET:String = "assets/dialogs/alaska/FV_BeatExpansion_xsu.swf";
      
      private static const DIALOG_BG_ASSET:String = "assets/dialogs/alaska/AnimalFrame.png";
      
      private static const FEATURE_NAME:String = "beatalaskaExpansionA";
      
      private static const LOC_PREFIX:String = "BeatAlaskaExpansion_";
      
      private static const ICON_NAME:String = "BeatAlaskaExpansion";
      
      private static const STAT_COUNTER_NAME:String = "beat_alaska";
      
      public function BeatAlaskaExpansionManager(key:SingletonEnforcer)
      {
         GlobalEngine.assert(key != null,"[BeatAlaskaExpansionManager] :: Use instance()");
         super(FEATURE_NAME,LOC_PREFIX,ICON_NAME,STAT_COUNTER_NAME);
      }
      
      public static function get instance() : BeatAlaskaExpansionManager
      {
         if(!s_instance)
         {
            s_instance = new BeatAlaskaExpansionManager(new SingletonEnforcer());
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
