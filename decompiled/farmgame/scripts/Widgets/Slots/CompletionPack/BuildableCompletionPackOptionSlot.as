package Widgets.Slots.CompletionPack
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.BuildableCompletionPackagesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CompletionPack.BuildableCompletionPackWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BuildableCompletionPackOptionSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:BuildableCompletionPackWindow = null;
      
      protected var m_data:Object = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_packageNameTextField:ZwTextField = null;
      
      private var m_packageNameText:String = "";
      
      private var m_packageSubTextField:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_value:ZwTextField = null;
      
      private var m_buyable:Boolean = false;
      
      public function BuildableCompletionPackOptionSlot(element:DisplayObject, parentWindow:BuildableCompletionPackWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("copy_tf"))
         {
            this.m_packageNameTextField = addWidget(new ZwTextField(m_element.copy_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("text_tf"))
         {
            this.m_packageSubTextField = addWidget(new ZwTextField(m_element.text_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("buy_bt"))
         {
            this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,ZLocUtils.t_pk("Dialogs","FinishNow"),"0",this.onSelectButtonClick)) as FarmAnimatedCashButton;
         }
         if(m_element.hasOwnProperty("value_tf"))
         {
            this.m_value = addWidget(new ZwTextField(m_element.value_tf,"")) as ZwTextField;
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_packageNameTextField = null;
         this.m_packageSubTextField = null;
         this.m_buyButton = null;
         this.m_value = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_data.cost > 0)
            {
               this.m_buyable = true;
            }
            if(this.m_icon != null)
            {
               this.m_icon.loadIcon(Global.getAssetURL(this.m_data.image));
               this.m_icon.visible = true;
            }
            if(this.m_packageNameTextField != null)
            {
               this.m_packageNameText = ZLocUtils.t("Dialogs",this.m_data.title);
               this.m_packageNameTextField.text = this.m_packageNameText;
               this.m_packageNameTextField.visible = true;
            }
            if(this.m_packageSubTextField != null)
            {
               this.m_packageSubTextField.text = ZLocUtils.t("Dialogs",this.m_data.subtext,{"cost":this.m_data.cost.toString()});
               this.m_packageSubTextField.visible = true;
            }
            if(this.m_buyButton != null)
            {
               this.m_buyButton.setAmountText(this.m_data.cost.toString());
               this.m_buyButton.visible = true;
               this.m_buyButton.enabled = this.m_buyable;
            }
            if(this.m_value != null)
            {
               this.m_value.text = ZLocUtils.t("Dialogs","completion_pack_value",{"cost":this.m_data.originalCost});
               this.m_value.visible = true;
            }
         }
      }
      
      private function onSelectButtonClick(event:MouseEvent) : void
      {
         FarmStatsManager.count("Dialog","clicks",BuildableCompletionPackagesManager.MAIN_WINDOW_STAT);
         if(Global.player.canBuyCash(this.m_data.cost,true))
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","completionPack_buy_conformation",{
               "cost":this.m_data.cost.toString(),
               "option":this.m_packageNameText
            }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyDialog,"",true);
         }
         this.m_parentWindow.close();
      }
      
      private function onConfirmBuyDialog(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            Global.player.cash -= this.m_data.cost;
            Global.player.setSeenFlag(BuildableCompletionPackagesManager.COMPLETION_PACK_BOUGHT);
            Global.hud.rightSideIconQueue.removeIconByName(BuildableCompletionPackagesManager.ICON_TYPE_COMPLETION_PACK);
            BuildableCompletionPackagesManager.getInstance().completeBuildingByOption(this.m_data.name);
         }
      }
   }
}

