package Widgets.Slots
{
   import Managers.GuildEventManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class GuildMembersStatuSlot extends ZwSlotFrame
   {
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_checkMark:MovieClip;
      
      private const PROGRESS_BAR_FULL_ANGLE:int = 360;
      
      public function GuildMembersStatuSlot(element:DisplayObject, featureName:String)
      {
         super(element);
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkMark = m_element["checkmark_mc"] as MovieClip;
            this.m_checkMark.visible = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var icon:FarmIcon = new FarmIcon(m_element["profile_mc"] as MovieClip,data.pic_square);
         icon.setIconSize(40,40);
         icon.detachTooltip();
         icon.visible = true;
         if(data.hasOwnProperty("name") && data.name != null && data.name != "")
         {
            icon.attachTooltip(new FarmTextTooltip(data.name));
            if(this.m_toolTip)
            {
               this.m_toolTip.setText(data.name);
            }
            else
            {
               icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(data.name));
            }
         }
         if(data.hasOwnProperty("entry_status"))
         {
            this.m_checkMark.visible = data["entry_status"];
            if(data["entry_status"])
            {
               icon.attachTooltip(this.m_toolTip = new FarmTextTooltip(data.name + " has joined this event!"));
            }
         }
         var keyCount:int = 0;
         if(data.hasOwnProperty("keyCount"))
         {
            keyCount = int(data["keyCount"]);
         }
         if(data["entry_status"] == true)
         {
            keyCount = GuildEventManager.getInstance().getKeysRequiredForCurrentEvent();
         }
         var barAngle:Number = keyCount * this.PROGRESS_BAR_FULL_ANGLE / GuildEventManager.getInstance().getKeysRequiredForCurrentEvent();
         if(m_element.fill_mc)
         {
            m_element.fill_mc.rotation = barAngle;
            m_element.fill_mc.visible = true;
            if(keyCount <= 50)
            {
               m_element.left_mc.visible = true;
               m_element.right_mc.visible = false;
            }
            else if(keyCount >= 50)
            {
               m_element.left_mc.visible = false;
               m_element.right_mc.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

