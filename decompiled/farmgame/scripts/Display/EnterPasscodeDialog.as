package Display
{
   import Classes.LootableDecoration;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Transactions.TOpenLockedBox;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   
   public class EnterPasscodeDialog extends Dialog
   {
      
      protected const MAX_CHARS:Number = 1;
      
      private var m_accept:GenericButton;
      
      protected var m_lootItem:LootableDecoration;
      
      public function EnterPasscodeDialog(lootItem:LootableDecoration)
      {
         m_dialogAsset = "assets/dialogs/FV_lockedBox_passcode.swf";
         super();
         this.m_lootItem = lootItem;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         Global.stage.focus = m_window.mysteryBox_mc.digit1_tf;
         this.setPasscodeProps(m_window.mysteryBox_mc.digit1_tf);
         this.setPasscodeProps(m_window.mysteryBox_mc.digit2_tf);
         this.setPasscodeProps(m_window.mysteryBox_mc.digit3_tf);
         this.setPasscodeProps(m_window.mysteryBox_mc.digit4_tf);
         m_window.mysteryBox_mc.error_mc.visible = false;
         this.m_accept = new GenericButton(m_window.mysteryBox_mc.ok_bt,this.onSendMessage);
         this.m_accept.text = ZLocUtils.t("Dialogs","Send");
         m_window.mysteryBox_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
      }
      
      private function setPasscodeProps(tf:TextField) : void
      {
         tf.maxChars = this.MAX_CHARS;
         tf.multiline = false;
         tf.text = " 8 ";
         tf.restrict = "A-Z a-z 0-9";
         tf.type = TextFieldType.INPUT;
         tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         tf.addEventListener(FocusEvent.FOCUS_IN,function(event:FocusEvent):void
         {
            event.target.setSelection(0,event.target.text.length);
         });
         tf.addEventListener(MouseEvent.MOUSE_DOWN,function(event:MouseEvent):void
         {
            event.target.setSelection(0,event.target.text.length);
         });
      }
      
      private function onKeyUp(event:KeyboardEvent) : void
      {
         m_window.mysteryBox_mc.error_mc.visible = false;
      }
      
      private function getPasscode() : String
      {
         return m_window.mysteryBox_mc.digit1_tf.text + m_window.mysteryBox_mc.digit2_tf.text + m_window.mysteryBox_mc.digit3_tf.text + m_window.mysteryBox_mc.digit4_tf.text;
      }
      
      private function onCancel(event:MouseEvent) : void
      {
         this.onCloseClick(event);
      }
      
      private function onSendMessage(event:MouseEvent) : void
      {
         if(this.getPasscode().length == 4)
         {
            if(m_window.mysteryBox_mc.close_bt.hasEventListener(MouseEvent.CLICK))
            {
               m_window.mysteryBox_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
            }
            this.m_accept.disabled = true;
            m_window.mysteryBox_mc.error_mc.visible = true;
            m_window.mysteryBox_mc.error_mc.sorry_tf.text = ZLocUtils.t("Dialogs","lockedbox_ValidatePasscode");
            TransactionManager.addTransaction(new TOpenLockedBox(this.m_lootItem,Global.player.snUser.uid.toString(),this.getPasscode(),this.invalidPasscode,this.onCloseClick),true);
         }
         else
         {
            this.invalidPasscode();
         }
      }
      
      private function invalidPasscode(showMsg:Boolean = true) : void
      {
         Global.stage.focus = m_window.mysteryBox_mc.digit1_tf;
         if(showMsg)
         {
            m_window.mysteryBox_mc.error_mc.visible = true;
            m_window.mysteryBox_mc.error_mc.sorry_tf.text = ZLocUtils.t("Dialogs","lockedbox_InvalidPasscode");
         }
         else
         {
            m_window.mysteryBox_mc.error_mc.visible = false;
         }
         this.m_accept.disabled = false;
         if(!m_window.mysteryBox_mc.close_bt.hasEventListener(MouseEvent.CLICK))
         {
            m_window.mysteryBox_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
         }
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         m_window.mysteryBox_mc.ok_bt.removeEventListener(MouseEvent.CLICK,this.onSendMessage);
         m_window.mysteryBox_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.mysteryBox_mc.error_mc.visible = false;
         if(event)
         {
            event.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
   }
}

