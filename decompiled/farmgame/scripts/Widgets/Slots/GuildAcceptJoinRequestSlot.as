package Widgets.Slots
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GuildAcceptJoinRequestSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_message_tf:ZwTextField;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_name_tf:ZwTextField;
      
      private var checkmark_mc:MovieClip;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_decline_bt:FarmAnimatedTextButton;
      
      private var m_invite_bt:FarmAnimatedTextButton;
      
      public function GuildAcceptJoinRequestSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],"0"));
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_element["accept_bt"],"Accept",this.onAcceptClick));
            this.m_accept_bt.visible = true;
         }
         if(m_element.hasOwnProperty("decline_bt"))
         {
            addWidget(this.m_decline_bt = new FarmAnimatedTextButton(m_element["decline_bt"],"Decline",this.onDeclineClick));
            this.m_decline_bt.visible = true;
         }
         if(m_element.hasOwnProperty("invite_bt"))
         {
            addWidget(this.m_invite_bt = new FarmAnimatedTextButton(m_element["invite_bt"],"Invite",null));
            this.m_invite_bt.visible = false;
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.checkmark_mc = m_element["checkmark_mc"] as MovieClip;
            this.checkmark_mc.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data.index;
         if(this.m_isIconPreviewAdded == true)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview.detachTooltip();
         }
         var icon:FarmIcon = new FarmIcon(m_element["icon_mc"] as MovieClip,this.m_data.pic_square);
         icon.setIconSize(30,30);
         icon.detachTooltip();
         icon.visible = true;
         if(this.m_name_tf)
         {
            this.m_name_tf.text = this.m_data.name;
            this.m_name_tf.visible = true;
         }
      }
      
      public function onAcceptClick(e:Event) : void
      {
      }
      
      public function onDeclineClick(e:Event) : void
      {
      }
   }
}

