package Widgets.Frames.CreditsBuilding
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ProgressSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      private var m_data:Object;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_priceTextField:ZwTextField;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_redeemCallback:Function;
      
      private var m_whatIsThis:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      public function ProgressSlot(element:DisplayObject, redeemCallback:Function, featureName:String = null)
      {
         this.m_redeemCallback = redeemCallback;
         this.m_featureName = featureName ? featureName : "RewardCredits";
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.itemTitle_tf)) as ZwTextField;
         this.m_priceTextField = addWidget(new ZwTextField(m_element.costs_tf,"")) as ZwTextField;
         this.m_redeemButton = addWidget(new FarmAnimatedTextButton(m_element.redeem_bt,"",this.onRedeemButtonClick)) as FarmAnimatedTextButton;
         if(m_element.whatisthis_mc)
         {
            this.m_whatIsThis = new FarmAnimatedTextButton(m_element.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.onClickWhatIsThisItem);
            addWidget(this.m_whatIsThis);
         }
         if(m_element.redeemGray_bt)
         {
            m_element.redeemGray_bt.visible = false;
            m_element.redeemGray_bt.enabled = false;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var showItemInfo:Boolean = false;
         var itemPK:String = null;
         var costPK:String = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_data.friendlyName)
            {
               this.m_nameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_data.friendlyName);
               this.m_nameTextField.visible = true;
            }
            if(this.m_data.icon)
            {
               this.m_icon.loadIcon(this.m_data.icon);
               this.m_icon.visible = true;
            }
            if(this.m_data.cost)
            {
               this.m_priceTextField.visible = true;
               itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_featureName);
               costPK = "Dialogs:RewardCredits_Simple_ItemCost";
               if("" != itemPK && ZLocUtils.isObject(itemPK))
               {
                  costPK = RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"ItemCost");
                  if("" == costPK)
                  {
                     costPK = "Dialogs:RewardCredits_ItemCost";
                  }
                  this.m_priceTextField.text = ZLocUtils.t_pk(costPK,null,{
                     "quantity":ZLocUtils.formatNumber(this.m_data.cost),
                     "item":ZLocUtils.tk_pk(itemPK,"",this.m_data.cost)
                  });
               }
               else
               {
                  this.m_priceTextField.text = ZLocUtils.t_pk(costPK,null,{"quantity":ZLocUtils.formatNumber(this.m_data.cost)});
               }
            }
            this.m_redeemButton.text = ZLocUtils.t("Dialogs","RewardCredits_Redeem");
            showItemInfo = Boolean(this.m_data.showInfo) && !this.m_data.locked;
            if(showItemInfo && "true" == this.m_data.whatIsThis)
            {
               this.m_whatIsThis.visible = true;
               this.m_whatIsThis.enabled = true;
            }
            else
            {
               this.m_whatIsThis.visible = false;
               this.m_whatIsThis.enabled = false;
            }
            this.m_redeemButton.visible = true;
         }
      }
      
      public function resizeIcon(newSize:Number) : void
      {
         this.m_icon.setIconSize(newSize,newSize);
      }
      
      private function onClickWhatIsThisItem(event:Event) : void
      {
         var redeemItemData:Object = this.m_data;
         var dialog:GenericPopupTitle = new GenericPopupTitle(redeemItemData.name + "Title",redeemItemData.name + "Message");
         dialog.setAcceptTextName("Okay");
         UI.displayPopup(dialog,false);
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      private function onRedeemButtonClick(evt:Event) : void
      {
         if(this.m_redeemButton.enabled)
         {
            if(this.m_redeemCallback != null && Boolean(this.m_data))
            {
               this.m_redeemCallback(this.m_data);
            }
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_nameTextField = null;
         this.m_icon = null;
         this.m_priceTextField = null;
         this.m_redeemButton = null;
         this.m_redeemCallback = null;
         this.m_whatIsThis = null;
         super.release();
      }
   }
}

