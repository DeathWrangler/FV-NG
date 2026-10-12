package Widgets.Windows.QuestManager
{
   import Classes.util.ZLocUtils;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class QMWReplayableQuestsCompletedSlot extends QMWReplayableQuestsBaseSlot
   {
      
      public function QMWReplayableQuestsCompletedSlot(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
         m_startQuestButton.text = ZLocUtils.t("Dialogs","QuestManagerV2_replayableCompletedQuestsReplayButtonText");
         if(m_blank != null)
         {
            m_blank.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","QuestManagerV2_replayableCompletedQuestsEmptySlotText")));
         }
      }
      
      override protected function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         showTooltipButtonOrText();
      }
   }
}

