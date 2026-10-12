package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.StencilManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class StencilSlot extends ZwSlotFrame
   {
      
      private var m_totemPreview:FarmIcon;
      
      private var m_useBtn:FarmAnimatedTextButton;
      
      private var m_cashBtn:FarmAnimatedTextButton;
      
      private var m_coinBtn:FarmAnimatedTextButton;
      
      private var m_name:ZwTextField;
      
      private var m_newIdentifier:ZwWidget;
      
      private var m_item:FarmItem;
      
      public function StencilSlot(element:DisplayObject)
      {
         super(element);
         addWidget(this.m_totemPreview = new FarmIcon(m_element.icon_mc));
         addWidget(this.m_useBtn = new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","Use"),this.onUse),false);
         addWidget(this.m_cashBtn = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","Buy"),this.onBuy),false);
         addWidget(this.m_coinBtn = new FarmAnimatedTextButton(m_element.coins_bt,ZLocUtils.t("Dialogs","Buy"),this.onBuy),false);
         addWidget(this.m_name = new ZwTextField(m_element.name_tf));
         addWidget(this.m_newIdentifier = new ZwWidget(m_element.new_icon));
      }
      
      private function get manager() : StencilManager
      {
         return StencilManager.instance();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_totemPreview = null;
         this.m_useBtn = null;
         this.m_cashBtn = null;
         this.m_coinBtn = null;
         this.m_name = null;
         this.m_newIdentifier = null;
         this.m_item = null;
      }
      
      public function populateSlot(data:Object) : void
      {
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(data.name);
         this.m_totemPreview.loadIcon(this.manager.getTotemPreviewURL(this.m_item));
         this.m_name.text = this.m_item.friendlyTitle;
         this.m_newIdentifier.visible = data.isNew;
         this.m_useBtn.visible = this.manager.ownsStencil(this.m_item.name);
         this.m_cashBtn.visible = !this.manager.ownsStencil(this.m_item.name);
         this.m_name.visible = true;
         this.m_totemPreview.setIconHeight(m_element.icon_mc.height);
         this.m_totemPreview.setIconWidth(m_element.icon_mc.width);
         this.m_totemPreview.visible = true;
         this.displaySlotButton(this.m_item);
      }
      
      private function hideAllButtons() : void
      {
         this.m_cashBtn.visible = false;
         this.m_coinBtn.visible = false;
         this.m_useBtn.visible = false;
      }
      
      private function displaySlotButton(item:FarmItem) : void
      {
         this.hideAllButtons();
         if(this.manager.ownsStencil(item.name))
         {
            this.m_useBtn.visible = true;
         }
         else if(item.currency == "cash")
         {
            this.m_cashBtn.visible = true;
            this.m_cashBtn.element.cost_tf.text = item.cash.toString();
         }
         else
         {
            this.m_coinBtn.visible = true;
            this.m_coinBtn.element.cost_tf.text = item.cost.toString();
         }
      }
      
      private function onUse(e:Event) : void
      {
         this.manager.onUse(this.m_item);
      }
      
      private function onBuy(e:Event) : void
      {
         this.manager.onBuy(this.m_item);
      }
   }
}

