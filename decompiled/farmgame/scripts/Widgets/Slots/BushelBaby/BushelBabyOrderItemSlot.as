package Widgets.Slots.BushelBaby
{
   import Classes.BushelBaby.BushelBabyOrderItem;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.BushelBabyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BushelBabyOrderItemSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:BushelBabyOrderItem;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_countTextField:ZwTextField;
      
      private var m_craftButton:FarmAnimatedTextButton;
      
      public function BushelBabyOrderItemSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_icon.attachTooltip(new FarmTextTooltip(""));
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf,"")) as ZwTextField;
         this.m_craftButton = addWidget(new FarmAnimatedTextButton(m_element.craft_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ejHNoPartsLabel"),this.onCraftClick,true)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_checkWidget = null;
         this.m_countTextField = null;
         this.m_data = null;
         this.m_craftButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as BushelBabyOrderItem;
         if(this.m_data)
         {
            this.m_icon.loadIcon(this.m_data.item.iconUrl);
            this.m_icon.visible = true;
            (this.m_icon.tooltip as FarmTextTooltip).setText(this.m_data.item.friendlyTitle);
            this.m_countTextField.text = this.m_data.itemCount + "/" + this.m_data.numRequired;
            this.m_countTextField.visible = true;
            this.m_checkWidget.visible = this.m_data.hasEnough;
            this.m_craftButton.visible = !this.m_checkWidget.visible;
         }
      }
      
      private function onCraftClick(e:MouseEvent) : void
      {
         BushelBabyManager.instance.showCraftingUI(this.m_data,this.onCraftClose);
      }
      
      private function onCraftClose() : void
      {
         BushelBabyNPCSlot(this.parent.parent).showOrderTooltip();
      }
   }
}

