package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Engine.Utilities;
   import GameMode.GMFarmstamatic;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmstamaticMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_motd_farmstamatic.swf";
      
      private var m_accept:MovieClip = null;
      
      public function FarmstamaticMOTDWindow()
      {
         if(Utilities.isFullScreen())
         {
            Utilities.setFullScreen(false);
         }
         super(ASSET_URL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.mainWindow));
         (m_window.mainWindow.arrow as MovieClip).visible = true;
         this.m_accept = m_window.mainWindow.accept_mc as MovieClip;
         this.m_accept.visible = true;
         this.m_accept.addEventListener(MouseEvent.CLICK,this.onAcceptClick);
         m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClickClose)) as FarmButton;
         m_closeButton.visible = false;
         var expVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMSTAMATIC_PHOTO_ONBOARDING_MOTD);
         if(expVariant == 2)
         {
            m_closeButton.visible = true;
         }
      }
      
      public function onClickClose(evt:MouseEvent) : void
      {
         super.onClose(evt);
      }
      
      public function onAcceptClick(event:MouseEvent) : void
      {
         onClose(event);
         Global.world.addGameMode(new GMFarmstamatic(),true);
      }
   }
}

