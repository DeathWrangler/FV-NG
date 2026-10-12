package Widgets.Windows.MOTD
{
   import Display.UI;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class LandBundleWinternordComingSoonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public function LandBundleWinternordComingSoonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 4 tiles at a discount. Hurry! Offer lasts till Sep 27th!");
         new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 120 Wrapping Papers free and use them to unlock tiers on the Daily Meter in the Gifts of Yuletide!");
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

