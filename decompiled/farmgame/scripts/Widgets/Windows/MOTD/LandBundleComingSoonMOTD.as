package Widgets.Windows.MOTD
{
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LandBundleComingSoonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function LandBundleComingSoonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Score 4 and get more on the Great Winter Plain.");
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Grab 4 tiles at a great discount and get a cool interactive deco free! Watch your avatar make snow angels with this cool deco!");
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

