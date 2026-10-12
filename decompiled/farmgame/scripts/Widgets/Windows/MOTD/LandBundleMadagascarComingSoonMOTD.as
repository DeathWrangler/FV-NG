package Widgets.Windows.MOTD
{
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LandBundleMadagascarComingSoonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function LandBundleMadagascarComingSoonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 4 tiles at a great discount. Coming March 16th, 2020!");
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get exclusive Animal and consumable pack for free!");
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

