package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Widgets.Core.Frames.ZwWindowSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ItemMembershipBonusSlot extends ZwWindowSlotFrame
   {
      
      private var m_checkBox:MovieClip;
      
      private var m_questionMark:MovieClip;
      
      private var m_bonusIcon:FarmIcon;
      
      private var m_numMonthsTextField:ZwTextField;
      
      public function ItemMembershipBonusSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
         if(m_element["check_mc"])
         {
            this.m_checkBox = m_element.check_mc;
            this.m_checkBox.visible = false;
         }
         if(m_element["questionmark_mc"])
         {
            this.m_questionMark = m_element.questionmark_mc;
            this.m_questionMark.visible = true;
         }
         if(m_element["icon_mc"])
         {
            this.m_bonusIcon = new FarmIcon(m_element.icon_mc);
            this.m_bonusIcon.setIconSize(100,100);
            addWidget(this.m_bonusIcon);
         }
         if(m_element["generic_tf"])
         {
            this.m_numMonthsTextField = new ZwTextField(m_element.generic_tf);
            addWidget(this.m_numMonthsTextField);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         if(m_tooltip)
         {
            detachTooltip();
         }
         if(data)
         {
            if(data["bonusItemName"])
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(data.bonusItemName);
               if(Boolean(item) && Boolean(this.m_bonusIcon))
               {
                  this.m_bonusIcon.loadIcon(item.iconUrl);
                  this.m_bonusIcon.visible = true;
               }
               if(this.m_questionMark)
               {
                  this.m_questionMark.visible = false;
               }
               if(this.m_checkBox)
               {
                  this.m_checkBox.visible = true;
               }
            }
            else if(data["tooltipText"])
            {
               if(this.m_bonusIcon)
               {
                  this.m_bonusIcon.visible = false;
               }
               if(this.m_questionMark)
               {
                  this.m_questionMark.visible = true;
               }
               if(this.m_checkBox)
               {
                  this.m_checkBox.visible = false;
               }
               attachTooltip(new FarmTextTooltip(data.tooltipText));
            }
            if(Boolean(this.m_numMonthsTextField) && Boolean(data["numRequiredMonths"]))
            {
               this.m_numMonthsTextField.text = data.numRequiredMonths + "months";
               this.m_numMonthsTextField.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_checkBox = null;
         this.m_questionMark = null;
         this.m_bonusIcon = null;
         this.m_numMonthsTextField = null;
         detachTooltip();
         super.release();
      }
   }
}

