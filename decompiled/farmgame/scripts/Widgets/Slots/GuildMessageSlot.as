package Widgets.Slots
{
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUD;
   import Managers.GuildManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GuildMessageSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_message_tf:ZwTextField;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_isIconPreviewAdded:Boolean = false;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_slotType:String;
      
      private var m_feed_tf:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_chatBG:MovieClip;
      
      private var m_name_tf:ZwTextField;
      
      private var m_time_tf:ZwTextField;
      
      public function GuildMessageSlot(element:DisplayObject, featureName:String, slotType:String)
      {
         this.m_featureName = featureName;
         this.m_slotType = slotType;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("message_tf"))
         {
            addWidget(this.m_message_tf = new ZwTextField(m_element["message_tf"],"0"));
         }
         if(m_element.hasOwnProperty("feed_tf"))
         {
            addWidget(this.m_feed_tf = new ZwTextField(m_element["feed_tf"],"0"));
         }
         if(m_element.hasOwnProperty("profile_mc"))
         {
            this.m_icon = new FarmIcon(m_element["profile_mc"] as MovieClip);
            this.m_icon.visible = false;
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],"0"));
         }
         if(m_element.hasOwnProperty("time_tf"))
         {
            addWidget(this.m_time_tf = new ZwTextField(m_element["time_tf"],"0"));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var myZid:String = null;
         var playerName:String = null;
         super.populate(data);
         this.m_data = data;
         this.m_icon.visible = false;
         if(m_element["chatBG_mc"])
         {
            this.m_chatBG = m_element["chatBG_mc"] as MovieClip;
            this.m_chatBG.visible = false;
         }
         if(this.m_slotType == "sent" || this.m_slotType == "received")
         {
            myZid = GuildManager.getInstance().getZId();
            if(this.m_slotType == "received" && this.m_data.playerId == myZid)
            {
               m_element.visible = false;
               return;
            }
            if(this.m_slotType == "sent" && this.m_data.playerId != myZid)
            {
               m_element.visible = false;
               return;
            }
         }
         this.m_slotIndex = this.m_data.index;
         if(this.m_isIconPreviewAdded == true)
         {
            removeWidget(this.m_iconPreview);
            this.m_iconPreview.detachTooltip();
         }
         if(this.m_data.hasOwnProperty("pic_square"))
         {
            this.m_icon.loadIcon(this.m_data.pic_square);
            this.m_icon.setIconSize(30,30);
            this.m_icon.detachTooltip();
            this.m_icon.visible = true;
         }
         if(this.m_chatBG)
         {
            this.m_chatBG.visible = true;
         }
         if(this.m_message_tf)
         {
            if(this.m_slotType == "feed")
            {
               this.m_message_tf.text = this.m_data.text;
               this.m_message_tf.visible = true;
            }
            else
            {
               playerName = this.m_data.name ? this.m_data.name : "Player";
               this.m_message_tf.text = this.m_data.text;
               this.m_name_tf.text = playerName;
               this.m_name_tf.visible = true;
               this.m_time_tf.text = HUD.getformattedTimeLeft(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_data.time) + " ago";
               this.m_time_tf.visible = true;
               this.m_message_tf.visible = true;
            }
         }
         if(this.m_feed_tf)
         {
            this.m_feed_tf.text = this.m_data.text;
            this.m_feed_tf.visible = true;
            this.m_time_tf.text = HUD.getformattedTimeLeft(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - this.m_data.time) + " ago";
            this.m_time_tf.visible = true;
         }
         if(this.m_data.hasOwnProperty("name") && this.m_data.name != null && this.m_data.name != "")
         {
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(this.m_data.name);
            }
            else
            {
               this.m_icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(this.m_data.name));
            }
         }
      }
   }
}

