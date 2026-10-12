package Classes.Avatar
{
   import Classes.FarmvilleClothingLoader;
   import Classes.IUser;
   import Display.ToolTip;
   import MyLife.NPC.SimpleNPC;
   import flash.events.MouseEvent;
   
   public class PartyAvatarUI extends SimpleNPC
   {
      
      public var m_toolTip:ToolTip;
      
      public function PartyAvatarUI(friendId:String, avatarScale:Number = 0.2)
      {
         var friend:IUser = null;
         super(new FarmvilleClothingLoader(),avatarScale);
         this.visible = true;
         if(friendId == Global.player.uid)
         {
            friend = Global.player;
         }
         else
         {
            friend = Global.friendManager.getAppFriendData(friendId);
         }
         var customizationData:Object = null;
         if(friend)
         {
            customizationData = friend.avatarData;
            this.m_toolTip = new ToolTip();
            this.m_toolTip.toolTip = friend.name;
         }
         if(!customizationData)
         {
            customizationData = FarmAvatar.getDefaultAvatarCustomizationData();
         }
         setAvatarCustomizationData(customizationData);
         if(null != this.m_toolTip)
         {
            Global.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
         }
      }
      
      public function onStageMouseMove(event:MouseEvent) : void
      {
         if(null != this.m_toolTip)
         {
            if(hitTestPoint(event.stageX,event.stageY,true))
            {
               this.m_toolTip.show();
               this.m_toolTip.updatePosition();
            }
            else
            {
               this.m_toolTip.hide();
            }
         }
      }
      
      override public function cleanUp() : void
      {
         super.cleanUp();
         Global.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove);
      }
   }
}

