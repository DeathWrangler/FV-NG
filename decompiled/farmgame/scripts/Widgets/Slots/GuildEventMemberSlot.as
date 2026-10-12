package Widgets.Slots
{
   import Managers.GuildEventManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuildEventMemberSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_cpoints_tf:ZwTextField;
      
      private var m_slotIndex:int;
      
      private var m_data:Object;
      
      private var m_role_tf:ZwTextField;
      
      private var m_name_tf:ZwTextField;
      
      private var m_hover_mc:MovieClip;
      
      private var m_highlight_mc:MovieClip;
      
      private var m_tasks_tf:ZwTextField;
      
      private var m_points_tf:ZwTextField;
      
      private var m_helps_tf:ZwTextField;
      
      private var m_rankicon_mc:MovieClip;
      
      private var m_helpicon_mc:MovieClip;
      
      private var m_taskicon_mc:MovieClip;
      
      private var m_points_icon_mc:MovieClip;
      
      private var m_pointsIconFrame:ZwFrame;
      
      private var m_tasksIconFrame:ZwFrame;
      
      private var m_helpsIconFrame:ZwFrame;
      
      private var m_rankIconFrame:ZwFrame;
      
      private var m_position_mc:MovieClip;
      
      private var m_positionTf:ZwTextField;
      
      private var m_rankToolTip:FarmTextTooltip;
      
      public function GuildEventMemberSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         (m_element as MovieClip).visible = true;
         if(m_element.hasOwnProperty("role_tf"))
         {
            addWidget(this.m_role_tf = new ZwTextField(m_element["role_tf"],""));
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_name_tf = new ZwTextField(m_element["name_tf"],""));
         }
         if(m_element.hasOwnProperty("tasks_tf"))
         {
            addWidget(this.m_tasks_tf = new ZwTextField(m_element["tasks_tf"],""));
         }
         if(m_element.hasOwnProperty("points_tf"))
         {
            addWidget(this.m_points_tf = new ZwTextField(m_element["points_tf"],""));
         }
         if(m_element.hasOwnProperty("helps_tf"))
         {
            addWidget(this.m_helps_tf = new ZwTextField(m_element["helps_tf"],""));
         }
         if(m_element.hasOwnProperty("rankicon_mc"))
         {
            this.m_rankicon_mc = m_element["rankicon_mc"] as MovieClip;
            this.m_rankicon_mc.visible = true;
         }
         if(m_element.hasOwnProperty("position_mc"))
         {
            this.m_position_mc = m_element["position_mc"] as MovieClip;
            this.m_position_mc.visible = true;
            if(this.m_position_mc.hasOwnProperty("position_tf"))
            {
               addWidget(this.m_positionTf = new ZwTextField(this.m_position_mc["position_tf"],""));
               this.m_positionTf.visible = true;
            }
            this.m_rankIconFrame = new ZwFrame(this.m_position_mc);
            this.m_rankIconFrame.attachTooltip(this.m_rankToolTip = new FarmTextTooltip("Rank"));
         }
         if(m_element.hasOwnProperty("points_icon_mc"))
         {
            this.m_points_icon_mc = m_element["points_icon_mc"] as MovieClip;
            this.m_points_icon_mc.visible = true;
            this.m_pointsIconFrame = new ZwFrame(this.m_points_icon_mc);
            this.m_pointsIconFrame.attachTooltip(new FarmTextTooltip("Event Score"));
         }
         if(m_element.hasOwnProperty("helps_icon_mc"))
         {
            this.m_helpicon_mc = m_element["helps_icon_mc"] as MovieClip;
            this.m_helpicon_mc.visible = true;
            this.m_helpsIconFrame = new ZwFrame(this.m_helpicon_mc);
            this.m_helpsIconFrame.attachTooltip(new FarmTextTooltip("Number of tasks helped by individuals"));
         }
         if(m_element.hasOwnProperty("tasks_icon_mc"))
         {
            this.m_taskicon_mc = m_element["tasks_icon_mc"] as MovieClip;
            this.m_taskicon_mc.visible = true;
            this.m_tasksIconFrame = new ZwFrame(this.m_taskicon_mc);
            this.m_tasksIconFrame.attachTooltip(new FarmTextTooltip("Number of tasks completed by individuals"));
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
            else
            {
               this.m_role_tf.text = "Member";
               this.m_rankicon_mc.gotoAndStop(4);
            }
            this.m_role_tf.visible = true;
         }
         if(Boolean(this.m_tasks_tf) && this.m_data.hasOwnProperty("taskCompleted"))
         {
            this.m_tasks_tf.text = this.m_data["taskCompleted"];
            this.m_tasks_tf.visible = true;
         }
         if(Boolean(this.m_points_tf) && this.m_data.hasOwnProperty("OBPoints"))
         {
            this.m_points_tf.text = this.m_data["OBPoints"];
            this.m_points_tf.visible = true;
         }
         if(Boolean(this.m_helps_tf) && this.m_data.hasOwnProperty(GuildEventManager.HELPED_TASK_COUNT))
         {
            this.m_helps_tf.text = this.m_data[GuildEventManager.HELPED_TASK_COUNT];
            this.m_helps_tf.visible = true;
         }
         if(Boolean(this.m_positionTf) && this.m_data.hasOwnProperty("rank"))
         {
            this.m_positionTf.text = this.m_data["rank"].toString();
            this.m_positionTf.visible = true;
            if(this.m_data["rank"].toString() == "-")
            {
               this.m_rankToolTip.setText("Contribute at least 50 points to be eligible for Rank Rewards!");
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
      }
   }
}

