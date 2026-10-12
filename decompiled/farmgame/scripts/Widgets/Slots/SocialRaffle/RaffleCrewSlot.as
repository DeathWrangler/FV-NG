package Widgets.Slots.SocialRaffle
{
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Managers.SocialRaffleManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenLite;
   import com.greensock.easing.Bounce;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class RaffleCrewSlot extends ZwSlotFrame
   {
      
      private var m_noIconImage:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
      
      private var m_friendImage:FarmIcon;
      
      private var m_ticketNumber:FarmTextField;
      
      private var m_clickCallback:Function = null;
      
      private var m_originalPosition:Point = null;
      
      private var m_glideUp:Boolean = false;
      
      public function RaffleCrewSlot(element:DisplayObject, clickCallback:Function = null)
      {
         super(element);
         this.addWidget(this.m_friendImage = new FarmIcon(this.element.friendimage_mc));
         this.addWidget(this.m_ticketNumber = new FarmTextField(this.element.ticketnumber_tf,""));
         this.m_ticketNumber.selectable = false;
         if(clickCallback != null)
         {
            this.m_clickCallback = clickCallback;
            this.registerEventListener(MouseEvent.CLICK,this.m_clickCallback);
            this.registerEventListener(MouseEvent.ROLL_OVER,this.rollOver);
            this.registerEventListener(MouseEvent.ROLL_OUT,this.rollOut);
         }
         this.m_originalPosition = new Point(this.x,this.y);
      }
      
      override public function release() : void
      {
         TweenLite.killTweensOf(this);
         this.unregisterEventListener(MouseEvent.CLICK,this.m_clickCallback);
         this.unregisterEventListener(MouseEvent.ROLL_OVER,this.rollOver);
         this.unregisterEventListener(MouseEvent.ROLL_OUT,this.rollOut);
         super.release();
      }
      
      private function rollOver(e:MouseEvent) : void
      {
         (this.element as MovieClip).buttonMode = true;
         (this.element as MovieClip).useHandCursor = true;
         if(this.m_ticketNumber.text.length == 0 && Global.animationState == Global.ANIMATION_STATE_PLAY && this.m_glideUp)
         {
            TweenLite.to(this,0.5,{
               "alpha":1,
               "y":this.m_originalPosition.y
            });
         }
      }
      
      private function rollOut(e:MouseEvent) : void
      {
         (this.element as MovieClip).buttonMode = false;
         (this.element as MovieClip).useHandCursor = false;
         if(this.m_ticketNumber.text.length == 0 && Global.animationState == Global.ANIMATION_STATE_PLAY && this.m_glideUp)
         {
            TweenLite.to(this,2,{
               "alpha":0.5,
               "y":this.m_originalPosition.y + 5,
               "ease":Bounce.easeOut
            });
         }
      }
      
      override public function populate(data:Object) : void
      {
         var friend:Friend = null;
         var tickets:Array = null;
         var obj:Object = null;
         var iconUrl:String = null;
         super.populate(data);
         this.m_ticketNumber.visible = true;
         this.m_friendImage.visible = true;
         if(data.hasOwnProperty("friendUid") && data.friendUid != null)
         {
            friend = Global.friendManager.getFriendData(data.friendUid);
            tickets = SocialRaffleManager.getInstance().userRaffleTickets;
            for each(obj in tickets)
            {
               if(obj.uid == data.friendUid)
               {
                  this.m_ticketNumber.text = obj.number;
                  break;
               }
            }
            this.m_friendImage.detachTooltip();
            if(friend)
            {
               iconUrl = friend.picture;
               this.m_friendImage.loadIcon(iconUrl);
               this.m_friendImage.attachTooltip(new FarmTextTooltip(friend.name));
            }
         }
         else if(this.m_clickCallback != null)
         {
            this.detachTooltip();
            this.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","socialrafflebuilding_blank_ticket")));
         }
         if(Global.animationState == Global.ANIMATION_STATE_PLAY)
         {
            TweenLite.from(this,3,{
               "delay":0.5,
               "alpha":0,
               "onComplete":this.fadeOutUnusedTickets,
               "x":0
            });
         }
      }
      
      private function fadeOutUnusedTickets() : void
      {
         if(this.m_ticketNumber.text.length == 0 && Global.animationState == Global.ANIMATION_STATE_PLAY)
         {
            TweenLite.to(this,2,{
               "delay":2,
               "alpha":0.5,
               "y":this.m_originalPosition.y + 5,
               "onComplete":function():void
               {
                  m_glideUp = true;
               }
            });
         }
      }
      
      public function set callback(value:Function) : void
      {
         this.unregisterEventListener(MouseEvent.CLICK,this.m_clickCallback);
         this.m_clickCallback = value;
         this.registerEventListener(MouseEvent.CLICK,this.m_clickCallback);
      }
   }
}

