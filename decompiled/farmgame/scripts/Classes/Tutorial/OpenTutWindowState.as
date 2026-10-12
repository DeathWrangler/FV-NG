package Classes.Tutorial
{
   import Classes.Managers.HUDTutorialManager;
   import Display.UI;
   import Widgets.Windows.FarmWindowWithTutorial;
   import flash.events.Event;
   
   public class OpenTutWindowState implements IHUDTutorialState
   {
      
      protected static const EVENT_NAME:String = "TutorialWindow";
      
      private var m_completed:Boolean = false;
      
      protected var m_ftueConfig:Object;
      
      public function OpenTutWindowState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var assetName:String = this.m_ftueConfig.asset;
         Global.player.setSeenFlagAdmin(OpenTutWindowState.EVENT_NAME + "_Tutorial",false);
         UI.displayPopup(new FarmWindowWithTutorial(OpenTutWindowState.EVENT_NAME,assetName,-1,true,false,true),false,"OpenTutWindow",true);
         Global.world.addEventListener(OpenTutWindowState.EVENT_NAME,this.updateProgress);
      }
      
      protected function updateProgress(event:Event) : void
      {
         this.m_completed = true;
         HUDTutorialManager.instance.step();
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
         Global.world.removeEventListener(OpenTutWindowState.EVENT_NAME,this.updateProgress);
      }
   }
}

