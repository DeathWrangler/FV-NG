package Widgets.Slots
{
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.GuildEventManager;
   import Managers.GuildManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuildMemberSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_cpoints_tf:ZwTextField;
      
      private var m_removePlayerBt:FarmAnimatedTextButton;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_role_tf:ZwTextField;
      
      private var m_name_tf:ZwTextField;
      
      private var m_hover_mc:MovieClip;
      
      private var m_highlight_mc:MovieClip;
      
      private var m_otherGuildView:Boolean;
      
      private var m_rankicon_mc:MovieClip;
      
      private var m_coop_pointsIcon_mc:MovieClip;
      
      private var m_coop_pointsIconFrame:ZwFrame;
      
      private var m_rankIconFrame:ZwFrame;
      
      private var m_icon:FarmIcon;
      
      public function GuildMemberSlot(element:DisplayObject, featureName:String, otherGuildView:Boolean)
      {
         this.m_featureName = featureName;
         super(element);
         this.m_otherGuildView = otherGuildView;
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("cpoints_tf"))
         {
            addWidget(this.m_cpoints_tf = new ZwTextField(m_element["cpoints_tf"],""));
         }
         if(m_element.hasOwnProperty("cpoints_icon_mc"))
         {
            this.m_coop_pointsIcon_mc = m_element["cpoints_icon_mc"] as MovieClip;
            this.m_coop_pointsIcon_mc.visible = true;
            this.m_coop_pointsIconFrame = new ZwFrame(this.m_coop_pointsIcon_mc);
            this.m_coop_pointsIconFrame.attachTooltip(new FarmTextTooltip("Total Stat Points"));
         }
         if(m_element.hasOwnProperty("role_tf"))
         {
            addWidget(this.m_role_tf = new ZwTextField(m_element["role_tf"],""));
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],""));
         }
         if(m_element.hasOwnProperty("remove_bt"))
         {
            addWidget(this.m_removePlayerBt = new FarmAnimatedTextButton(m_element["remove_bt"],"Remove",null));
            this.m_removePlayerBt.visible = false;
            this.m_removePlayerBt.attachTooltip(new FarmTextTooltip("Leader, Co-Leader and General have the authority to remove any member from the clan"));
         }
         if(m_element.hasOwnProperty("hover_mc"))
         {
            this.m_hover_mc = m_element["hover_mc"] as MovieClip;
            this.m_hover_mc.visible = false;
            (this.m_hover_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hover_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         if(m_element.hasOwnProperty("highlight_mc"))
         {
            this.m_highlight_mc = m_element["highlight_mc"] as MovieClip;
            this.m_highlight_mc.visible = false;
         }
         if(m_element.hasOwnProperty("rankicon_mc"))
         {
            this.m_rankicon_mc = m_element["rankicon_mc"] as MovieClip;
            this.m_rankicon_mc.visible = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         var icon:FarmIcon = new FarmIcon(m_element["profile_mc"] as MovieClip,this.m_data.pic_square);
         icon.setIconSize(50,50);
         icon.detachTooltip();
         icon.visible = true;
         if(this.m_data.hasOwnProperty("name") && this.m_data.name != null && this.m_data.name != "")
         {
            this.m_name_tf.text = this.m_data["name"];
            this.m_name_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty("role") && this.m_data.role != null && this.m_data.role != "")
         {
            if(this.m_data.role == "Owner")
            {
               this.m_role_tf.text = "Leader";
               this.m_rankicon_mc.gotoAndStop(1);
            }
            else if(this.m_data.role == "Leader")
            {
               this.m_role_tf.text = "Co-Leader";
               this.m_rankicon_mc.gotoAndStop(2);
            }
            else if(this.m_data.role == "Elder")
            {
               this.m_role_tf.text = "General";
               this.m_rankicon_mc.gotoAndStop(3);
            }
            else
            {
               this.m_role_tf.text = "Member";
               this.m_rankicon_mc.gotoAndStop(4);
            }
            this.m_rankIconFrame = new ZwFrame(this.m_rankicon_mc);
            this.m_rankIconFrame.attachTooltip(new FarmTextTooltip("Rank"));
            this.m_role_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty(GuildManager.PLAYER_GUILD_POINTS))
         {
            this.m_cpoints_tf.text = this.m_data[GuildManager.PLAYER_GUILD_POINTS];
            this.m_cpoints_tf.visible = true;
         }
         if(this.m_otherGuildView)
         {
            this.m_removePlayerBt.visible = false;
            this.m_highlight_mc.visible = false;
            this.m_hover_mc.visible = false;
         }
         else if(this.m_data.hasOwnProperty("playerId"))
         {
            if(this.m_data["playerId"] == GuildManager.getInstance().getZId())
            {
               this.m_highlight_mc.visible = true;
            }
            else
            {
               this.m_highlight_mc.visible = false;
            }
         }
         this.m_removePlayerBt.visible = false;
         if(!this.m_otherGuildView)
         {
            if(this.m_data["entry_status"] == 0 || GuildEventManager.isEventOver() == true)
            {
               if(GuildManager.getInstance().isOwner())
               {
                  if(this.m_data.role != "Owner")
                  {
                     this.m_removePlayerBt.callback = this.onRemovePlayerButtonClick;
                     this.m_removePlayerBt.visible = true;
                  }
               }
               else if(GuildManager.getInstance().isLeader())
               {
                  if(this.m_data.role == "Member")
                  {
                     this.m_removePlayerBt.visible = true;
                     this.m_removePlayerBt.callback = this.onRemovePlayerButtonClick;
                  }
               }
               else
               {
                  this.m_removePlayerBt.visible = false;
               }
            }
         }
      }
      
      private function onConfirmRemovePlayer(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GuildManager.getInstance().removePlayerFromGuild(this.m_data.playerId);
         }
      }
      
      public function onRemovePlayerButtonClick(e:Event) : void
      {
         var message:String = "Are you sure you want to remove this player from clan?";
         UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmRemovePlayer,"",true);
      }
      
      override public function release() : void
      {
         if(this.m_hover_mc)
         {
            (this.m_hover_mc as MovieClip).removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            (this.m_hover_mc as MovieClip).removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         }
         super.release();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = true;
            this.m_removePlayerBt.visible = true;
         }
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         if(this.m_hover_mc)
         {
            this.m_hover_mc.visible = false;
            this.m_removePlayerBt.visible = false;
         }
      }
   }
}

