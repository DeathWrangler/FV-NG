package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class DragonBreedingEventMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_date_tf:FarmTextField;
      
      public function DragonBreedingEventMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onAccept(ev:MouseEvent) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t_pk(m_currentMOTD["linkURL"])),"_blank");
         close();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            if(m_window["mainWindow"].hasOwnProperty("date_tf"))
            {
               this.m_date_tf = addWidget(new FarmTextField(m_window.mainWindow.date_tf,ZLocUtils.t("Dialogs","dragon_breeding_event_text")),true) as FarmTextField;
            }
         }
      }
   }
}

