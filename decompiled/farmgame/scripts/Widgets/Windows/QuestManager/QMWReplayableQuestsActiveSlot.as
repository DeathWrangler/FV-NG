package Widgets.Windows.QuestManager
{
   import Classes.Quest.FarmQuestManager;
   import Classes.util.ZLocUtils;
   import Display.Quests.QuestProgressBar;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class QMWReplayableQuestsActiveSlot extends QMWReplayableQuestsBaseSlot
   {
      
      private var m_isFeaturedQuest:Boolean = false;
      
      private var m_featuredText:FarmTextField = null;
      
      private var m_progressBar:QuestProgressBar = null;
      
      public function QMWReplayableQuestsActiveSlot(element:DisplayObject, mainWindow:QuestManagerWindowV2)
      {
         super(element,mainWindow);
         if(m_blank != null)
         {
            m_blank.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","QuestManagerV2_ActiveFrame_EmptySlotTooltip")));
            m_blank.registerEventListener(MouseEvent.CLICK,this.onEmptySlotClick);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(m_farmQuest != null)
         {
            this.m_isFeaturedQuest = !FarmQuestManager.getInstance().isQuestActive(m_farmQuest.name);
         }
         if(this.m_isFeaturedQuest)
         {
            if(this.m_featuredText == null && m_element.hasOwnProperty("featured_tf") && m_element["featured_tf"] != null)
            {
               this.m_featuredText = addWidget(new FarmTextField(m_element.featured_tf,ZLocUtils.t("Dialogs","QuestManagerV2_featuredQuestText"))) as FarmTextField;
            }
            if(this.m_featuredText != null)
            {
               this.m_featuredText.visible = true;
            }
         }
         else if(m_element.hasOwnProperty("progressbar_mc") && m_element["progressbar_mc"] != null)
         {
            this.m_progressBar = new QuestProgressBar(145,105,0.5,0.5);
            m_element.addChild(this.m_progressBar);
            this.m_progressBar.playAnimation(m_farmQuest.progressByTasks,false);
         }
      }
      
      override protected function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         if(this.m_isFeaturedQuest)
         {
            m_startQuestButton.visible = true;
            if(this.m_featuredText != null)
            {
               this.m_featuredText.visible = false;
            }
         }
         else
         {
            m_viewQuestButton.visible = true;
            m_endQuestButton.visible = true;
         }
      }
      
      override protected function onMouseOut(event:MouseEvent) : void
      {
         super.onMouseOut(event);
         if(this.m_featuredText != null)
         {
            this.m_featuredText.visible = true;
         }
      }
      
      private function onEmptySlotClick(event:MouseEvent) : void
      {
         m_mainWindow.showNewReplayableQuestsFrame();
      }
      
      override public function clearView() : void
      {
         super.clearView();
         if(this.m_progressBar != null)
         {
            m_element.removeChild(this.m_progressBar);
            this.m_progressBar = null;
         }
      }
   }
}

