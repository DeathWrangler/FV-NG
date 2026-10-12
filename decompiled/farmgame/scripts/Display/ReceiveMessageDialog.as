package Display
{
   import Classes.Avatar.FarmAvatar;
   import Classes.EmbeddedArt;
   import Classes.FarmvilleClothingLoader;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import MyLife.NPC.SimpleNPC;
   import Transactions.TGetAvatarData;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class ReceiveMessageDialog extends Dialog
   {
      
      private const AVATAR_SCALE:Number = 1.5;
      
      private var m_message:String = "";
      
      private var m_name:String;
      
      private var m_:int;
      
      private var m_accept:GenericButton;
      
      private var m_cancel:GenericButton;
      
      private var m_report:GenericButton;
      
      private var m_authorPlayer:IUser;
      
      private var m_authorId:String;
      
      public function ReceiveMessageDialog(uid:String)
      {
         m_dialogAsset = "assets/dialogs/FV_receiveMessage.swf";
         this.m_authorId = uid;
         super();
      }
      
      public function set message(message:String) : void
      {
         if(message)
         {
            this.m_message = message;
         }
      }
      
      private function addFacebookPic() : void
      {
         var pic:DisplayObject = null;
         var urlPic:String = null;
         if(this.m_authorPlayer)
         {
            urlPic = this.m_authorPlayer.picture;
            if(urlPic)
            {
               pic = LoadingManager.load(urlPic);
            }
         }
         if(pic == null)
         {
            pic = new EmbeddedArt.hud_no_profile_pic();
            pic.width = 48;
            pic.height = 48;
         }
         pic.x = 6;
         pic.y = 6;
         m_window.receiveMessage_mc.fbImage_mc.addChild(pic);
      }
      
      private function addAvatar() : void
      {
         var character:SimpleNPC = new SimpleNPC(new FarmvilleClothingLoader());
         var avatarData:Object = null;
         if(Boolean(this.m_authorPlayer) && Boolean(this.m_authorPlayer.avatar))
         {
            avatarData = this.m_authorPlayer.avatar.getAvatarCustomizationData();
         }
         else
         {
            avatarData = FarmAvatar.getDefaultAvatarCustomizationData();
         }
         character.setAvatarCustomizationData(avatarData);
         character.x = 60;
         character.y = 180;
         character.scaleX = character.scaleY = this.AVATAR_SCALE;
         m_window.receiveMessage_mc.avatar_mc.addChild(character);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.receiveMessage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.m_report = new GenericButton(m_window.receiveMessage_mc.reportAbuse_bt,this.onReportAbuse);
         this.m_report.text = ZLocUtils.t("Dialogs","Report");
         this.m_accept = new GenericButton(m_window.receiveMessage_mc.keepIt_bt);
         this.m_accept.text = ZLocUtils.t("Dialogs","Keep");
         this.m_cancel = new GenericButton(m_window.receiveMessage_mc.delete_bt);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Delete");
         this.m_accept.turnOff();
         this.m_cancel.turnOff();
         m_window.receiveMessage_mc.messaging_tf.text = this.m_message;
         TransactionManager.addTransaction(new TGetAvatarData(this.m_authorId,this.onLoadAuthorData),true);
      }
      
      private function onLoadAuthorData(player:IUser) : void
      {
         if(player)
         {
            this.m_authorPlayer = player;
            this.m_name = player.name;
            this.addAvatar();
            this.addFacebookPic();
            if(!this.m_name)
            {
               this.m_name = "";
            }
            m_window.receiveMessage_mc.title_tf.text = ZLocUtils.t("Dialogs","ReceiveMessage",{"user":ZLocUtils.tn(this.m_name,ZLocUtils.tg(player.snUser.gender))});
         }
      }
      
      private function onReportAbuse(event:MouseEvent) : void
      {
         var abuseEmail:String = "mailto:farmvillereport@zynga.com?subject=Farmville Abuse for Facebook Id " + this.m_authorId.toString();
         navigateToURL(new URLRequest(abuseEmail),"");
         this.onCloseClick(event);
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         var friend:Friend = null;
         super.onCloseClick(event);
         if(this.m_authorId != Global.player.snUser.uid && (Global.worldManager.isVisiting() && Global.worldManager.getVisiting() != this.m_authorId.toString()))
         {
            friend = Global.friendManager.getFriendData(this.m_authorId);
            if(friend != null)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","VisitFarmConfirmation",{"user":ZLocUtils.tn(this.m_name,ZLocUtils.tg(this.m_authorPlayer.snUser.gender))}),GenericPopup.TYPE_ACCEPTCANCEL,this.visitFarm,"",false);
            }
         }
         m_window.receiveMessage_mc.reportAbuse_bt.removeEventListener(MouseEvent.CLICK,this.onReportAbuse);
         m_window.receiveMessage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         event.stopPropagation();
         close();
      }
      
      private function visitFarm(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            if(this.m_authorId)
            {
               Global.worldManager.visitNeighbor(this.m_authorId.toString());
            }
         }
      }
   }
}

