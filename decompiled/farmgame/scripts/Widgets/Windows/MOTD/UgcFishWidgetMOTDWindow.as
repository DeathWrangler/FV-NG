package Widgets.Windows.MOTD
{
   import Managers.WorldSeasonsManager;
   import Widgets.Core.Base.ZwWidget;
   
   public class UgcFishWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_eaIcon:ZwWidget;
      
      public function UgcFishWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.mainWindow["EA_mc"])
         {
            addWidget(this.m_eaIcon = new ZwWidget(m_window.mainWindow["EA_mc"]));
         }
         if(WorldSeasonsManager.getInstance().isGAFirstWeek("underwater"))
         {
            this.m_eaIcon.visible = false;
         }
      }
   }
}

