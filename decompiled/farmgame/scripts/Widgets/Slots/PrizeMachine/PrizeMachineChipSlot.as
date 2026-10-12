package Widgets.Slots.PrizeMachine
{
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class PrizeMachineChipSlot extends ZwSlotFrame
   {
      
      private var m_darkBackground:ZwBaseWidget;
      
      private var m_lightBackground:ZwBaseWidget;
      
      private var m_title:ZwTextField;
      
      private var m_wonMC:ZwBaseWidget;
      
      private var m_chipIcon:FarmIcon;
      
      public function PrizeMachineChipSlot(element:DisplayObject)
      {
         super(element);
         addWidget(this.m_darkBackground = new ZwBaseWidget(m_element.darkBackground_mc));
         addWidget(this.m_lightBackground = new ZwBaseWidget(m_element.lightBackground_mc));
         addWidget(this.m_title = new ZwTextField(m_element.greenText_tf,"Token"));
         addWidget(this.m_wonMC = new ZwBaseWidget(m_element.won_mc));
         addWidget(this.m_chipIcon = new FarmIcon(m_element.icon_mc));
         this.m_chipIcon.setIconSize(50,50);
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_title.visible = true;
         if(data.hasOwnProperty("collected") && Boolean(data.collected))
         {
            this.m_darkBackground.visible = false;
            this.m_lightBackground.visible = true;
            this.m_wonMC.visible = true;
            (this.m_chipIcon.element as MovieClip).filters = [];
         }
         else
         {
            this.m_darkBackground.visible = true;
            this.m_lightBackground.visible = false;
            this.m_wonMC.visible = false;
         }
      }
   }
}

