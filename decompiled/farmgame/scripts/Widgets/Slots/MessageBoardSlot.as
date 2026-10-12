package Widgets.Slots
{
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.MessageBoardManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MessageBoardFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.MessageBoardWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class MessageBoardSlot extends ZwSlotFrame
   {
      
      private static const FEATURE_FLASHPARAM_MESSAGE_BOARD:String = "FEATURE_FLASHPARAM_MESSAGE_BOARD";
      
      private var m_window:MessageBoardWindow;
      
      private var m_frame:MessageBoardFrame;
      
      private const FEATURE_NAME:String = "MessageBoard";
      
      private const MOTD:String = "MOTD";
      
      private const INNOVATION:String = "innovation";
      
      private const URL:String = "url";
      
      private const READ_MORE:String = "readmore";
      
      private const FEATURE:String = "FEATURE";
      
      private var m_category:* = "";
      
      private var m_cta:* = "";
      
      private var m_readmore:* = "";
      
      private var m_worldType:* = "";
      
      private var m_currentSlot_mc:MovieClip;
      
      private var m_plainTextTf:ZwTextField;
      
      private var m_newBadge_mc:MovieClip;
      
      private var m_textIcon_mc:MovieClip;
      
      private var m_msg_text_tf:ZwTextField;
      
      private var m_msg_icon:FarmIcon;
      
      private var m_cta_bt:FarmAnimatedTextButton;
      
      private var m_msgId:String;
      
      public function MessageBoardSlot(element:DisplayObject, window:MessageBoardWindow, frame:MessageBoardFrame)
      {
         super(element);
         this.m_window = window;
         this.m_frame = frame;
         this.visible = true;
         this.m_currentSlot_mc = element as MovieClip;
         if(this.m_currentSlot_mc)
         {
            this.m_currentSlot_mc.visible = true;
         }
         if(m_element.hasOwnProperty("just_text_tf"))
         {
            this.m_plainTextTf = new ZwTextField(m_element["just_text_tf"]);
            this.m_plainTextTf.visible = true;
         }
         if(m_element.hasOwnProperty("new_badge_mc"))
         {
            this.m_newBadge_mc = m_element["new_badge_mc"] as MovieClip;
            this.m_newBadge_mc.visible = false;
         }
         if(m_element.hasOwnProperty("text_icon_mc"))
         {
            this.m_textIcon_mc = m_element["text_icon_mc"] as MovieClip;
            this.m_textIcon_mc.visible = true;
         }
         if(Boolean(this.m_textIcon_mc) && this.m_textIcon_mc.hasOwnProperty("message_text_icon_tf"))
         {
            this.m_msg_text_tf = new ZwTextField(this.m_textIcon_mc["message_text_icon_tf"]);
            this.m_msg_text_tf.visible = true;
         }
         if(Boolean(this.m_textIcon_mc) && this.m_textIcon_mc.hasOwnProperty("message_icon_mc"))
         {
            this.m_msg_icon = addWidget(new FarmIcon(this.m_textIcon_mc["message_icon_mc"])) as FarmIcon;
            this.m_msg_icon.visible = false;
         }
         if(m_element.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_cta_bt = new FarmAnimatedTextButton(m_element.okay_bt,"Okay",this.onCTAButtonClick));
            this.m_cta_bt.visible = true;
         }
      }
      
      public function onCTAButtonClick(event:MouseEvent) : void
      {
         if(this.m_window)
         {
            this.m_window.close();
         }
         switch(this.m_category)
         {
            case this.MOTD:
               this.manager.triggerMOTDbyName(this.m_cta);
               break;
            case this.FEATURE:
               this.manager.openFeatureWindowFVTECurrency(this.m_cta);
               break;
            case this.INNOVATION:
               this.manager.triggerInnovationByName(this.m_cta,this.m_worldType);
               break;
            case this.URL:
               navigateToURL(new URLRequest(this.m_cta),"_blank");
               break;
            case this.READ_MORE:
               UI.displayMessage(this.m_readmore,GenericPopup.TYPE_OK,null,"farmAnimatedTextConfirmation",true,true);
               break;
            default:
               if(this.m_window)
               {
                  this.m_window.close();
               }
         }
         StatsManager.count("Message_Board_Neighbour_Bar","click_message",this.m_msgId,this.m_category,this.m_cta);
      }
      
      override public function populate(data:Object) : void
      {
         var category:String = null;
         var readmore:String = null;
         var msg_world:String = null;
         var cta:String = null;
         var fo:* = undefined;
         var msgCount:int = 0;
         var slotNum:int = 0;
         super.populate(data);
         if(data)
         {
            if(data.hasOwnProperty("icon") && data["icon"] != "")
            {
               this.m_msg_icon.loadIcon(data["icon"]);
               this.m_msg_icon.setIconSize(50,50);
               this.m_msg_icon.visible = true;
            }
            if(data.hasOwnProperty("msg"))
            {
               this.m_plainTextTf.text = data["msg"];
               this.m_msg_text_tf.text = data["msg"];
            }
            if(data.hasOwnProperty("icon") && data["icon"] != "")
            {
               this.m_textIcon_mc.visible = true;
               this.m_plainTextTf.visible = false;
               this.m_plainTextTf.text = "";
               this.m_msg_text_tf.visible = true;
            }
            else
            {
               this.m_plainTextTf.text = data["msg"];
               this.m_plainTextTf.visible = true;
               this.m_msg_text_tf.visible = false;
            }
            category = "";
            readmore = "";
            msg_world = "";
            cta = "";
            if(data.hasOwnProperty("category") && data["category"] != "")
            {
               category = data["category"];
               this.m_category = category;
            }
            if(data.hasOwnProperty("readmore"))
            {
               readmore = data["readmore"];
               this.m_readmore = readmore;
            }
            if(data.hasOwnProperty("msg_world"))
            {
               msg_world = data["msg_world"];
               this.m_worldType = msg_world;
            }
            if(data.hasOwnProperty("msgId"))
            {
               this.m_msgId = data["msgId"];
            }
            if(data.hasOwnProperty("cta") && data["cta"] != "")
            {
               cta = data["cta"];
               this.m_cta = cta;
               if(this.m_cta_bt)
               {
                  this.m_cta_bt.text = "Go!";
                  this.m_cta_bt.visible = true;
               }
            }
            fo = this.manager.getFeatureData();
            msgCount = 0;
            if(fo.hasOwnProperty("msgCount"))
            {
               msgCount = int(fo["msgCount"]);
            }
            slotNum = 0;
            if(data["slotNum"])
            {
               slotNum = int(data["slotNum"]);
            }
            if(msgCount > 0 && this.manager.getBadgeSlot(slotNum))
            {
               this.m_newBadge_mc.visible = true;
            }
            this.manager.setNewBadgeFalg(slotNum);
         }
      }
      
      private function get manager() : MessageBoardManager
      {
         return MessageBoardManager.getInstance(this.FEATURE_NAME);
      }
      
      private function getMessagetext() : String
      {
         var messagetext:String = "";
         if(Global.flashHotParams.hasOwnProperty("MESSAGE_BOARD"))
         {
            messagetext = Global.flashHotParams["MESSAGE_BOARD"];
         }
         return messagetext;
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

