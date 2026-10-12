package Classes.Tutorial
{
   import Classes.Constants.WorldsConstants;
   import Display.UI;
   import Managers.WorldSeasonsManager;
   import Widgets.Windows.JapanEATutorial;
   import Widgets.Windows.JapanTutorial;
   
   public class JapanTutWindowState extends OpenTutWindowState
   {
      
      private static const EVENT_NAME:String = "TutorialWindow";
      
      private var m_completed:Boolean = false;
      
      public function JapanTutWindowState(ftueConfig:Object)
      {
         super(ftueConfig);
      }
      
      override public function initialize() : void
      {
         var assetName:String = m_ftueConfig.asset;
         Global.player.setSeenFlagAdmin(OpenTutWindowState.EVENT_NAME + "_Tutorial",false);
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JAPAN))
         {
            UI.displayPopup(new JapanEATutorial(OpenTutWindowState.EVENT_NAME,"assets/dialogs/Japan/xjp_GlobalFTUE_EA.swf",8,true,false,true,true),false,"OpenTutWindow",true);
         }
         else
         {
            UI.displayPopup(new JapanTutorial(OpenTutWindowState.EVENT_NAME,"assets/dialogs/Japan/xjp_GlobalFTUE_GA.swf",7,true,false,true,true),false,"OpenTutWindow",true);
         }
         Global.world.addEventListener(EVENT_NAME,updateProgress);
      }
   }
}

