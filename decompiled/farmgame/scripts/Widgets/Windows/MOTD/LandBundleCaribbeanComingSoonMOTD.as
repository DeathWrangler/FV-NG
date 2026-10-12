package Widgets.Windows.MOTD
{
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LandBundleCaribbeanComingSoonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function LandBundleCaribbeanComingSoonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Grab 4 tiles at a great discount and you get the Beach Cafe for Fab’s Gourmet Delights for free!");
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Coming 7 May, 2018");
         UI.stopPopups(true);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

