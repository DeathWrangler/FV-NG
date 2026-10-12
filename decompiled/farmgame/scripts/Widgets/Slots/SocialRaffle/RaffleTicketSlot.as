package Widgets.Slots.SocialRaffle
{
   import Classes.Friend;
   import Classes.Player;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class RaffleTicketSlot extends ZwSlotFrame
   {
      
      private var m_ticketNumberTextField:ZwTextField;
      
      private var m_friendImageIcon:FarmIcon;
      
      private var m_startingPosition:Point = null;
      
      private var m_dissipated:Boolean = false;
      
      public function RaffleTicketSlot(element:DisplayObject)
      {
         super(element);
         this.m_ticketNumberTextField = new ZwTextField(m_element.ticketnumber_mc);
         addWidget(this.m_ticketNumberTextField);
         this.m_friendImageIcon = new FarmIcon(m_element.friendimage_mc);
         addWidget(this.m_friendImageIcon);
         this.m_startingPosition = new Point(m_element.x,m_element.y);
      }
      
      override public function release() : void
      {
         TweenLite.killTweensOf(this);
         super.release();
      }
      
      public function get dissipated() : Boolean
      {
         return this.m_dissipated;
      }
      
      public function resetPosition() : void
      {
         this.x = this.m_startingPosition.x;
         this.y = this.m_startingPosition.y;
         this.alpha = 1;
         this.visible = true;
         this.m_dissipated = false;
      }
      
      public function dissipate() : void
      {
         if(this.m_dissipated == false)
         {
            this.m_dissipated = true;
            TweenLite.to(this,1,{
               "y":this.m_startingPosition.y + 30,
               "alpha":0,
               "onComplete":this.onFinishDissipate
            });
         }
      }
      
      private function onFinishDissipate() : void
      {
         this.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         var iconUrl:String = null;
         var friendObj:Friend = null;
         super.populate(data);
         if(Boolean(data.number) && Boolean(data.uid))
         {
            this.m_ticketNumberTextField.text = data.number;
            this.m_ticketNumberTextField.visible = true;
            this.m_friendImageIcon.detachTooltip();
            iconUrl = Player.NO_PROFILE_PIC_URL;
            if(data.uid == "FC")
            {
               iconUrl = "assets/hud/fc_icon_50x50.png";
            }
            else if(data.uid != "GENERIC")
            {
               friendObj = Global.friendManager.getAppFriendData(data.uid);
               if(Boolean(friendObj) && Boolean(friendObj.picture))
               {
                  iconUrl = friendObj.picture;
                  this.m_friendImageIcon.attachTooltip(new FarmTextTooltip(friendObj.name));
               }
            }
            this.m_friendImageIcon.loadIcon(iconUrl);
            this.m_friendImageIcon.visible = true;
         }
      }
   }
}

