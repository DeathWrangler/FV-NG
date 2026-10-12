package Classes.Avatar
{
   import Classes.Friend;
   import GameMode.GMMessageSignPlace;
   import flash.events.MouseEvent;
   
   public class FriendAvatar extends FarmAvatar
   {
      
      protected var m_friendId:String;
      
      protected var m_friendName:String;
      
      protected var m_isFarmOwner:Boolean = false;
      
      protected var m_isStranger:Boolean;
      
      private var m_isFriendDataValid:Boolean;
      
      public function FriendAvatar(friendId:String, avatarData:Object = null, friendName:String = "", isStranger:Boolean = false)
      {
         var customizationData:Object = null;
         this.m_isStranger = isStranger;
         var friend:Friend = Global.friendManager.getAppFriendData(friendId);
         if(Global.worldManager.isVisiting() && avatarData != null)
         {
            customizationData = avatarData;
            this.m_friendName = friendName;
            this.m_isFriendDataValid = true;
         }
         else if(friend != null)
         {
            customizationData = friend.avatarData;
            this.m_friendName = friend.name;
            this.m_isFriendDataValid = true;
         }
         if(avatarData != null)
         {
            customizationData = avatarData;
         }
         if(!customizationData)
         {
            customizationData = FarmAvatar.getDefaultAvatarCustomizationData();
            this.m_isFriendDataValid = false;
         }
         super(customizationData);
         this.m_friendId = friendId;
         if(Global.worldManager.isVisiting())
         {
            this.m_isFarmOwner = Global.worldManager.getVisiting() == this.m_friendId ? true : false;
         }
      }
      
      public function getFriendId() : String
      {
         return this.m_friendId;
      }
      
      override protected function showClothingIndicator() : Boolean
      {
         return false;
      }
      
      override protected function showMessagingIndicator() : Boolean
      {
         return false;
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(!Global.worldManager.isVisiting())
         {
            setHighlighted(true);
            this.updateToolTipText();
            updateAvatarIndicator();
            conditionallyRedraw(true);
         }
      }
      
      override public function onMouseOut() : void
      {
         if(!Global.worldManager.isVisiting())
         {
            setHighlighted(false);
            setToolTip(null);
            updateAvatarIndicator(false);
            conditionallyRedraw(true);
         }
      }
      
      override public function onClick() : void
      {
         if(Boolean(isSelected()) && Boolean(Global.selectedAvatar) && !Global.worldManager.isVisiting())
         {
            if(this.showMessagingIndicator() && this.m_avatarMessagingIndicator != null)
            {
               AvatarMessagingIndicator.countClicksIndicator();
               Global.world.addGameMode(new GMMessageSignPlace("messageSign"));
               conditionallyRedraw(this.m_avatarMessagingIndicator.removeMessagingIndicator());
            }
         }
         if(!Global.worldManager.isVisiting())
         {
            setHighlighted(false);
            setToolTip(null);
         }
         if(!Global.worldManager.isVisiting())
         {
            setSelected(true);
         }
      }
      
      override public function isAttached() : Boolean
      {
         return true;
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         this.onClick();
      }
      
      override protected function updateToolTipText() : void
      {
         if(this.m_friendName)
         {
            setToolTip(this.m_friendName);
         }
      }
      
      public function hasValidFriendData() : Boolean
      {
         return this.m_isFriendDataValid;
      }
   }
}

