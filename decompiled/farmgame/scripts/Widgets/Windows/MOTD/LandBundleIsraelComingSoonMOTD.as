package Widgets.Windows.MOTD
{
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LandBundleIsraelComingSoonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function LandBundleIsraelComingSoonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 4 tiles at a great discount. Coming 17 Sep, 2018!");
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 20 Farm Off Chips free. Use them to redeem cool rewards on the Great Farm-Off!");
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

