package Widgets.Windows.MOTD
{
   import Classes.Quest.PrerequisiteUtility;
   import flash.events.Event;
   
   public class CheckRequireOnShowMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      protected var m_close:Boolean = false;
      
      public function CheckRequireOnShowMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override public function show() : void
      {
         if(PrerequisiteUtility.arePrerequisitesMet(m_currentMOTD["prereqs"]))
         {
            super.show();
         }
         else
         {
            this.m_close = true;
            this.close();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         m_currentMOTD = null;
         super.onClose(event);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         if(!this.m_close)
         {
            super.onLoadComplete(event);
         }
      }
   }
}

