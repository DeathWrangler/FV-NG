package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.Dialog;
   import Display.GenericPopup;
   import Display.MessageCenterDialog;
   import Display.ReceiveMessageDialog;
   import Display.UI;
   import Engine.Constants;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.MessageManager;
   import Transactions.TDeleteMessageSign;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class MessageSign extends MapResource
   {
      
      public static const SIGNPOST_MESSAGE:String = "signpost_message";
      
      private const MESSAGE_SIGN:String = "messageSign";
      
      protected const VIEW_POST:String = "viewPost";
      
      protected const MOVE_POST:String = "movePost";
      
      protected const DELETE_POST:String = "deletePost";
      
      private const STATE_NORMAL:String = "normal";
      
      private var m_messageId:Number = 0;
      
      private var m_message:String;
      
      private var m_timestamp:Number;
      
      private var m_authorId:String;
      
      private var m_hostId:String;
      
      public function MessageSign(authorId:String = "-1")
      {
         super(this.MESSAGE_SIGN);
         this.m_authorId = authorId;
         this.m_message = "";
         m_objectType = Constants.WORLDOBJECT_MESSAGE_SIGN;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      public function setMessage(localMessage:String) : void
      {
         if(localMessage)
         {
            this.m_message = localMessage;
         }
      }
      
      public function set authorId(authorId:String) : void
      {
         this.m_authorId = authorId;
      }
      
      public function get authorId() : String
      {
         return this.m_authorId;
      }
      
      public function set timestamp(timestamp:Number) : void
      {
         this.m_timestamp = timestamp;
      }
      
      public function get timestamp() : Number
      {
         return this.m_timestamp;
      }
      
      public function set hostId(hostId:String) : void
      {
         this.m_hostId = hostId;
      }
      
      public function get hostId() : String
      {
         return this.m_hostId;
      }
      
      public function setMessageId(messageId:Number) : void
      {
         this.m_messageId = messageId;
      }
      
      public function getMessageId() : Number
      {
         return this.m_messageId;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.message = this.m_message;
         obj.authorId = this.m_authorId.toString();
         obj.hostId = this.m_hostId != null ? this.m_hostId.toString() : this.m_hostId;
         obj.timestamp = this.m_timestamp;
         obj.messageId = this.m_messageId.toString();
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         m_depthPriority = 5;
         this.m_timestamp = data.timestamp;
         this.m_message = data.message;
         this.m_authorId = data.authorId;
         this.m_messageId = data.messageId;
         if(state == null)
         {
            setState(this.STATE_NORMAL);
         }
      }
      
      public function updateWithMessage(message:Message) : void
      {
         this.setMessage(message.getMessage());
         if(Global.worldManager.isVisiting())
         {
            this.hostId = Global.worldManager.getVisiting();
         }
         else
         {
            this.hostId = Global.player.snUser.uid;
         }
         this.timestamp = message.getTimestamp();
         this.authorId = message.getAuthorId();
         this.setMessageId(message.getId());
      }
      
      public function showMessage() : void
      {
         var dialog:Dialog = null;
         var receiveDialog:ReceiveMessageDialog = null;
         if(MessageManager.getInstance().canShowMessageCenter())
         {
            dialog = new MessageCenterDialog(this,true);
         }
         else
         {
            receiveDialog = new ReceiveMessageDialog(this.m_authorId);
            receiveDialog.message = this.m_message;
            dialog = receiveDialog;
         }
         var receiveMsgObj:DisplayObject = Global.stage.getChildByName("receiveMessagePopup");
         if(receiveMsgObj == null)
         {
            UI.displayPopup(dialog,true,"receiveMessagePopup",true);
         }
      }
      
      override public function getCurrentImageName() : String
      {
         return "normal";
      }
      
      override public function onClick() : void
      {
         if(Global.worldManager.isVisiting())
         {
            if(Global.player.snUser.uid == this.m_authorId)
            {
               this.showMenu();
            }
            else
            {
               this.showMessage();
            }
         }
         else
         {
            this.showMenu();
         }
         setHighlighted(false);
         setToolTip(null);
      }
      
      override public function showMenu() : void
      {
         var bgColor:uint = 0;
         var rollOverColor:uint = 0;
         if(!hasValidId() || this.m_messageId <= 0)
         {
            showObjectBusy();
         }
         else
         {
            bgColor = 16777215;
            rollOverColor = 11723263;
            UI.displayMenu(this.getMenuItems(),this.onMenuClick,bgColor,rollOverColor,true);
         }
      }
      
      protected function getMenuItems() : Array
      {
         var menuItems:Array = [{
            "label":ZLocUtils.t("FarmGame","ViewMessage"),
            "action":this.VIEW_POST
         }];
         if(!Global.worldManager.isVisiting())
         {
            menuItems.push({
               "label":ZLocUtils.t("FarmGame","MovePost"),
               "action":this.MOVE_POST
            });
         }
         menuItems.push({
            "label":ZLocUtils.t("FarmGame","DeletePost"),
            "action":this.DELETE_POST
         });
         return menuItems;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var deleteObj:DisplayObject = null;
         var mapResource:MapResource = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case this.VIEW_POST:
                  this.showMessage();
                  break;
               case this.MOVE_POST:
                  this.move();
                  break;
               case this.DELETE_POST:
                  deleteObj = Global.stage.getChildByName("deleteObjectPopup");
                  if(deleteObj == null)
                  {
                     mapResource = this as MapResource;
                     if(Boolean(mapResource) && Boolean(mapResource.getItem()))
                     {
                        UI.displayMessage(ZLocUtils.t("FarmGame","DeleteObjectSpecific",{"item":ZLocUtils.tk_pk(mapResource.getItem().friendlyName)}),GenericPopup.TYPE_YESNO,this.deletePostHandler,"deleteObjectPopup",true);
                     }
                     else
                     {
                        UI.displayMessage(ZLocUtils.t("FarmGame","DeleteObject"),GenericPopup.TYPE_YESNO,this.deletePostHandler,"deleteObjectPopup",true);
                     }
                  }
            }
         }
      }
      
      private function deletePostHandler(event:GenericPopupEvent) : void
      {
         var message:Message = null;
         var result:Boolean = event.button == GenericPopup.YES;
         if(result == true)
         {
            this.detach();
            if(Global.worldManager.isVisiting())
            {
               this.m_hostId = Global.worldManager.getVisiting();
            }
            else
            {
               this.m_hostId = Global.player.snUser.uid;
            }
            TransactionManager.addTransaction(new TDeleteMessageSign(this));
            message = MessageManager.getInstance().getMessageByMessageSignId(getId());
            if(message)
            {
               MessageManager.getInstance().removeMessage(message.getId(),false);
            }
         }
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return true;
      }
   }
}

