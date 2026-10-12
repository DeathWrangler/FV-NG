package Widgets.Frames
{
   import Managers.MessageBoardManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.MessageBoardSlot;
   import Widgets.Windows.MessageBoardWindow;
   import flash.display.DisplayObject;
   
   public class MessageBoardFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "message_item_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private var m_window:MessageBoardWindow;
      
      private var m_featureName:String = "MessageBoard";
      
      private var m_pieces:Array;
      
      private var m_headerTf:ZwTextField;
      
      public function MessageBoardFrame(element:DisplayObject, parentWindow:MessageBoardWindow, featureName:String = "")
      {
         this.m_window = parentWindow;
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty("consumable_header_tf"))
         {
            addWidget(this.m_headerTf = new ZwTextField(m_element["consumable_header_tf"],featureName));
            m_element["consumable_header_tf"].text = "Parts found";
            m_element["consumable_header_tf"].visible = true;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MessageBoardSlot(slotElement,this.m_window,this);
      }
      
      override protected function setupData() : void
      {
         var i:int = 0;
         m_slotData = [];
         this.setData();
         if(this.m_pieces.length == 2)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               m_slotData.push({
                  "msg":this.m_pieces[i]["msg"],
                  "icon":this.m_pieces[i]["icon"],
                  "category":this.m_pieces[i]["category"],
                  "cta":this.m_pieces[i]["cta"],
                  "readmore":this.m_pieces[i]["readmore"],
                  "slotNum":i + 1,
                  "msgId":this.m_pieces[i]["msgId"],
                  "msg_world":this.m_pieces[i]["msg_world"]
               });
            }
         }
         else if(this.m_pieces.length == 1)
         {
            for(i = 0; i < 1; i++)
            {
               m_slotData.push({
                  "msg":this.m_pieces[i]["msg"],
                  "icon":this.m_pieces[i]["icon"],
                  "category":this.m_pieces[i]["category"],
                  "cta":this.m_pieces[i]["cta"],
                  "readmore":this.m_pieces[i]["readmore"],
                  "slotNum":i + 1,
                  "msgId":this.m_pieces[i]["msgId"],
                  "msg_world":this.m_pieces[i]["msg_world"]
               });
            }
         }
         else
         {
            m_slotData.push({"msg":"\n No new messages! Keep Farming!"});
         }
      }
      
      public function setData() : void
      {
         var featureData:* = undefined;
         var msgData:Object = null;
         var index:* = undefined;
         var text:String = null;
         var iconUrl:String = null;
         var category:String = null;
         var cta:String = null;
         var readmore:String = null;
         var msgId:String = null;
         var msg_world:String = null;
         var msgDetails:Object = null;
         this.m_pieces = [];
         if(this.manager)
         {
            featureData = this.manager.getFeatureData();
            msgData = featureData["active"];
            if(msgData)
            {
               for(index = 0; index < msgData.length; index++)
               {
                  text = "";
                  iconUrl = "";
                  category = "";
                  cta = "";
                  readmore = "";
                  msgId = "";
                  msg_world = "";
                  if(msgData[index] != -1)
                  {
                     msgDetails = msgData[index];
                     text = msgDetails["msg"];
                     if(Boolean(msgDetails) && Boolean(msgDetails["icon"]))
                     {
                        iconUrl = msgDetails["icon"];
                     }
                     if(Boolean(msgDetails) && Boolean(msgDetails["category"]))
                     {
                        category = msgDetails["category"];
                     }
                     if(Boolean(msgDetails) && Boolean(msgDetails["cta"]))
                     {
                        cta = msgDetails["cta"];
                     }
                     if(Boolean(msgDetails) && Boolean(msgDetails["readmore"]))
                     {
                        readmore = msgDetails["readmore"];
                     }
                     if(Boolean(msgDetails) && Boolean(msgDetails["id"]))
                     {
                        msgId = msgDetails["id"];
                     }
                     if(Boolean(msgDetails) && Boolean(msgDetails["msg_world"]))
                     {
                        msg_world = msgDetails["msg_world"];
                     }
                  }
                  this.m_pieces[index] = {
                     "icon":iconUrl,
                     "category":category,
                     "cta":cta,
                     "msg":text,
                     "readmore":readmore,
                     "msgId":msgId,
                     "msg_world":msg_world
                  };
               }
            }
         }
      }
      
      private function get manager() : MessageBoardManager
      {
         return MessageBoardManager.getInstance(this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

