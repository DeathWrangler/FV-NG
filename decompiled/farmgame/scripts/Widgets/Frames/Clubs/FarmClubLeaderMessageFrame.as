package Widgets.Frames.Clubs
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FarmClubLeaderMessageFrame extends ZwFrame
   {
      
      private static const CHAR_LIMIT:int = 41;
      
      private var m_textEntry:ZwTextField = null;
      
      private var m_saveCallBack:Function = null;
      
      public function FarmClubLeaderMessageFrame(element:DisplayObject, currentText:String, onSaveCallback:Function)
      {
         super(element);
         this.m_saveCallBack = onSaveCallback;
         addWidget(new ZwTextField(m_element.title_mc,ZLocUtils.t("FarmClub","leaderMessageTitle")));
         this.m_textEntry = addWidget(new ZwTextField(m_element.leaderMessage_tf,currentText)) as ZwTextField;
         this.m_textEntry.selectable = true;
         (this.m_textEntry.element as TextField).maxChars = CHAR_LIMIT;
         addWidget(new FarmAnimatedTextButton(m_element.save_bt,ZLocUtils.t("Dialogs","CustomizeRingEditRing"),this.onSave));
         addWidget(new FarmAnimatedTextButton(m_element.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onCancel));
      }
      
      private function onSave(event:Event) : void
      {
         var text:String = this.m_textEntry.text;
         if(text.length > 0 && text.length <= CHAR_LIMIT)
         {
            FarmClubUtility.sendChatMessage(text,null);
            this.m_saveCallBack(FarmClubDataManager.getInstance().getFarmClubDataObject(true));
            this.onCancel(event);
         }
         else
         {
            UI.showMessage(ZLocUtils.t("FarmClub","enterMessage"));
         }
      }
      
      private function onCancel(event:Event) : void
      {
         this.visible = false;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_textEntry = null;
         this.m_saveCallBack = null;
      }
   }
}

