package Widgets.Frames.DuckPond
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.DuckPond.DuckGameRewardSlot;
   import Widgets.Windows.DuckPond.DuckGameWindow;
   import flash.display.DisplayObject;
   
   public class DuckGameRewardSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_duckGameWindow:DuckGameWindow;
      
      public function DuckGameRewardSlotFrame(element:DisplayObject, items:Array, duckGameWindow:DuckGameWindow)
      {
         this.m_items = items;
         this.m_duckGameWindow = duckGameWindow;
         super(element);
         addWidget(new ZwTextField(m_element.generic0_tf,ZLocUtils.t("Dialogs","DuckGame_Teaser")));
         addWidget(new ZwTextField(m_element.generic1_tf,ZLocUtils.t("Dialogs","DuckGame_GetFriends",{"quantity":this.m_duckGameWindow.friendsRequired})),false);
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs","DuckGame_ChooseDuck",{"quantity":this.m_duckGameWindow.totalFriendsRequired})),false);
         addWidget(new ZwTextField(m_element.timer_tf,ZLocUtils.t("Dialogs","DuckGame_Meter",{"quantity":int(this.m_duckGameWindow.daysLeft)})),false);
         addWidget(new ZwWidget(m_element.bar_mc),false);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DuckGameRewardSlot(slotElement,this.m_duckGameWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_duckGameWindow = null;
      }
      
      public function featureSetUpdate() : void
      {
         var name:String = null;
         var teaseText:ZwTextField = getWidget(m_element.generic0_tf) as ZwTextField;
         var getFriendsText:ZwTextField = getWidget(m_element.generic1_tf) as ZwTextField;
         var chooseText:ZwTextField = getWidget(m_element.generic2_tf) as ZwTextField;
         var meterText:ZwTextField = getWidget(m_element.timer_tf) as ZwTextField;
         var bar:ZwWidget = getWidget(m_element.bar_mc) as ZwWidget;
         if(this.m_duckGameWindow.rewardCode == "")
         {
            teaseText.text = ZLocUtils.t("Dialogs","DuckGame_Teaser");
         }
         else
         {
            name = Global.farmGameSettingsManager.getFarmItemByCode(this.m_duckGameWindow.rewardCode).friendlyName;
            teaseText.text = ZLocUtils.t("Dialogs","DuckGame_ThankMessage",{"item":ZLocUtils.tk_pk(name)});
         }
         if(this.m_duckGameWindow.friendsRequired == 0)
         {
            getFriendsText.visible = false;
            meterText.visible = false;
            bar.visible = false;
            if(this.m_duckGameWindow.daysLeft < 6)
            {
               chooseText.text = ZLocUtils.t("Dialogs","DuckGame_ChooseDuck",{"quantity":this.m_duckGameWindow.totalFriendsRequired});
               chooseText.visible = true;
            }
            else
            {
               chooseText.visible = false;
            }
         }
         else
         {
            getFriendsText.visible = true;
            chooseText.visible = false;
            meterText.visible = true;
            bar.visible = true;
            bar.element.fill_mc.scaleX = Math.min(1,(this.m_duckGameWindow.daysLeft + 0.6) / this.m_duckGameWindow.featureDays);
            getFriendsText.text = ZLocUtils.t("Dialogs","DuckGame_GetFriends",{"quantity":this.m_duckGameWindow.friendsRequired});
            if(this.m_duckGameWindow.daysLeft >= 2)
            {
               meterText.text = ZLocUtils.t("Dialogs","DuckGame_MeterPlural",{"quantity":int(this.m_duckGameWindow.daysLeft)});
            }
            else
            {
               meterText.text = ZLocUtils.t("Dialogs","DuckGame_Meter",{"quantity":int(this.m_duckGameWindow.daysLeft)});
            }
         }
         refresh();
      }
      
      public function update() : void
      {
         var slot:DuckGameRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.update();
         }
      }
      
      public function set chooseButtonsEnabled(newState:Boolean) : void
      {
         var slot:DuckGameRewardSlot = null;
         for each(slot in m_slots)
         {
            slot.chooseEnabled = newState;
         }
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

