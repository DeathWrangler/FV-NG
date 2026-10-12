package Display.HUD
{
   import Classes.EmbeddedArt;
   import Classes.util.ZLocUtils;
   import Display.FarmGameSprite;
   import Display.MessageCenterDialog;
   import Display.SpriteButton;
   import Display.UI;
   import Engine.Utilities;
   import Managers.MessageManager;
   import Managers.SocialActionsManager;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class MessageCenterButton extends SpriteButton
   {
      
      private static const X_POSITION:Number = 692;
      
      private static const Y_POSITION:Number = 80;
      
      private static const X_OFFSET_NEW_MESSAGE_COUNT:int = -13;
      
      private static const Y_OFFSET_NEW_MESSAGE_COUNT:int = -2;
      
      private static const WIDTH_NEW_MESSAGE_COUNT:int = 50;
      
      private var m_messageCenterNotifications:FarmGameSprite;
      
      private var m_notificationsBubble:Bitmap;
      
      private var m_newMessageCount:TextField;
      
      public function MessageCenterButton()
      {
         super(EmbeddedArt.FV_Message_Center_Button,EmbeddedArt.FV_Message_Center_Over,EmbeddedArt.FV_Message_Center_Down,this.openMessageCenter);
         this.x = X_POSITION;
         this.y = Y_POSITION;
         this.visible = false;
         this.toolTip = ZLocUtils.t("FarmGame","MessageHudIconTooltip");
         this.m_messageCenterNotifications = new FarmGameSprite();
         this.addChild(this.m_messageCenterNotifications);
      }
      
      override public function set visible(value:Boolean) : void
      {
         super.visible = false;
      }
      
      public function openMessageCenter(event:Event) : void
      {
         UI.displayPopup(new MessageCenterDialog());
      }
      
      public function setUpNotificationBubble() : void
      {
         var notif_fmt:TextFormat = null;
         var numNewNotifications:Number = NaN;
         var showNotif:Boolean = false;
         if(this.m_messageCenterNotifications)
         {
            if(null == this.m_notificationsBubble && null == this.m_newMessageCount)
            {
               notif_fmt = HUDFonts.MessageCenterButtonText;
               numNewNotifications = this.getNewNotificationBubbleCount();
               showNotif = numNewNotifications > 0;
               this.m_notificationsBubble = new EmbeddedArt.FV_Message_Notification();
               this.m_notificationsBubble.visible = showNotif;
               this.m_newMessageCount = new TextField();
               this.m_newMessageCount.x = X_OFFSET_NEW_MESSAGE_COUNT;
               this.m_newMessageCount.y = Y_OFFSET_NEW_MESSAGE_COUNT;
               this.m_newMessageCount.width = WIDTH_NEW_MESSAGE_COUNT;
               this.m_newMessageCount.autoSize = TextFieldAutoSize.CENTER;
               this.m_newMessageCount.defaultTextFormat = notif_fmt;
               this.m_newMessageCount.setTextFormat(notif_fmt);
               this.m_newMessageCount.embedFonts = true;
               this.m_newMessageCount.mouseWheelEnabled = false;
               Utilities.toggleInputOnlySelf(this.m_newMessageCount,false);
               this.m_newMessageCount.visible = showNotif;
               this.m_newMessageCount.text = numNewNotifications.toString();
               this.m_messageCenterNotifications.addChild(this.m_notificationsBubble);
               this.m_messageCenterNotifications.addChild(this.m_newMessageCount);
            }
            else
            {
               this.updateNotificationBubble();
            }
         }
      }
      
      public function updateNotificationBubble() : void
      {
         var count:Number = this.getNewNotificationBubbleCount();
         var showNotif:Boolean = count > 0;
         this.m_newMessageCount.text = count.toString();
         this.m_notificationsBubble.visible = showNotif;
         this.m_newMessageCount.visible = showNotif;
      }
      
      private function getNewNotificationBubbleCount() : Number
      {
         var numNewNotifications:Number = MessageManager.getInstance().getNumNewMessages();
         if(0 == numNewNotifications)
         {
            numNewNotifications = SocialActionsManager.getInstance().getNumNewActions();
         }
         return numNewNotifications;
      }
   }
}

