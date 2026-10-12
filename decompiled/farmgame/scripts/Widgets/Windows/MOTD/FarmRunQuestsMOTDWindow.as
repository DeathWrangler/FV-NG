package Widgets.Windows.MOTD
{
   import Classes.util.ObjectUtil;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunQuestsMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_counterMC:MovieClip;
      
      public function FarmRunQuestsMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
            if(ObjectUtil.pathExists(this.m_counterMC,["accept_bt","text_tf"]))
            {
               addWidget(new ZwTextField(this.m_counterMC.accept_bt.text_tf,"Get Set Go!"));
            }
         }
      }
   }
}

