package Widgets.Windows.MOTD
{
   import Classes.Constants.WorldsConstants;
   import Managers.WorldSeasonsManager;
   import Widgets.Core.Base.ZwWidget;
   import flash.events.MouseEvent;
   
   public class JMMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_infoAnimationMcGA:ZwWidget;
      
      private var m_infoAnimationMcEA:ZwWidget;
      
      public function JMMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.mainWindow.hasOwnProperty("infoGA_mc"))
         {
            this.m_infoAnimationMcGA = addWidget(new ZwWidget(m_window.mainWindow.infoGA_mc),true) as ZwWidget;
         }
         if(m_window.mainWindow.hasOwnProperty("infoEA_mc"))
         {
            this.m_infoAnimationMcEA = addWidget(new ZwWidget(m_window.mainWindow.infoEA_mc),true) as ZwWidget;
         }
         this.m_infoAnimationMcGA.visible = false;
         this.m_infoAnimationMcEA.visible = true;
         this.m_infoAnimationMcEA.element.play();
         var isEA:Boolean = WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_JUNGLE);
         if(m_currentMOTD.motdSeenFlag == "MOTD_JMINNOVATION_GA" && !isEA)
         {
            this.m_infoAnimationMcEA.visible = false;
            this.m_infoAnimationMcGA.visible = true;
            this.m_infoAnimationMcGA.element.play();
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         close();
      }
   }
}

