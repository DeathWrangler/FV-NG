package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   
   public class FarmVillageToolTipRewardSlot extends ZwSlotFrame
   {
      
      private var m_icon:FarmIcon;
      
      private var m_quantity:int;
      
      private var m_iconUrl:String;
      
      private var m_toolTipText:String;
      
      private var m_count:ZwTextField;
      
      public function FarmVillageToolTipRewardSlot(element:MovieClip, parentWindow:FarmWindow)
      {
         super(element);
         if(m_element["count_tf"])
         {
            this.m_count = new ZwTextField(m_element["count_tf"]);
            addWidget(this.m_count,false);
         }
         if(m_element["icon_mc"])
         {
            this.m_icon = new FarmIcon(m_element["icon_mc"]);
            addWidget(this.m_icon,false);
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var toolTipString:String = data["toolTip"];
         if(this.m_toolTipText != toolTipString)
         {
            if(Boolean(this.m_icon) && Boolean(this.m_icon.tooltip))
            {
               this.m_icon.tooltip.release();
               this.m_icon.detachTooltip();
            }
         }
         this.m_quantity = data["amount"];
         this.m_iconUrl = data["icon"];
         this.m_toolTipText = toolTipString;
         this.update();
      }
      
      public function update() : void
      {
         if(this.m_count)
         {
            this.m_count.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageRewardCount",{"count":this.m_quantity.toString()});
            this.m_count.visible = true;
         }
         if(this.m_icon)
         {
            this.m_icon.attachTooltip(new FarmTextTooltip(this.m_toolTipText));
            if(this.m_icon.iconUrl != this.m_iconUrl)
            {
               this.m_icon.loadIcon(this.m_iconUrl);
            }
            this.m_icon.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_iconUrl = null;
         this.m_toolTipText = null;
         this.m_count = null;
         super.release();
      }
   }
}

