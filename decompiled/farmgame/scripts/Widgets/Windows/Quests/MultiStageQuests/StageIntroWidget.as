package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StageIntroWidget extends AbstractStageWidget
   {
      
      protected var m_acceptButton:FarmAnimatedTextButton;
      
      protected var m_introTitle:FarmTextField;
      
      protected var m_introBody:FarmTextField;
      
      private var m_seenFlag:String;
      
      public function StageIntroWidget(element:DisplayObject, quest:FarmQuest, parentWindow:FarmWindow, stage:int)
      {
         super(element,quest,parentWindow,stage);
         this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t("Quests",m_farmQuest.textBundle + "_IntroButton"))) as FarmAnimatedTextButton;
         this.m_acceptButton.registerEventListener(MouseEvent.CLICK,this.onAcceptClick);
         this.m_introTitle = addWidget(new FarmTextField(m_element.title_tf,ZLocUtils.t("Quests",m_farmQuest.textBundle + "_IntroTitle"))) as FarmTextField;
         this.m_introBody = addWidget(new FarmTextField(m_element.description_tf,ZLocUtils.t("Quests",m_farmQuest.textBundle + "_IntroBody"))) as FarmTextField;
      }
      
      private function onAcceptClick(event:MouseEvent) : void
      {
         this.visible = false;
         this.m_acceptButton.enabled = false;
         dispatchEvent(new Event(Event.CLOSE));
         m_farmQuest.setIntroSeen();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_acceptButton.unregisterEventListener(MouseEvent.CLICK,this.onAcceptClick);
      }
   }
}

