package Widgets.Windows.QuestManager
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class QMWReplayableQuestsNewSlot extends QMWReplayableQuestsBaseSlot
   {
      
      public function QMWReplayableQuestsNewSlot(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
      }
      
      override protected function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         showTooltipButtonOrText();
      }
   }
}

