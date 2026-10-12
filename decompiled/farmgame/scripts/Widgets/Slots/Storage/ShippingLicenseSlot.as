package Widgets.Slots.Storage
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericFarmCashButton;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TBuyConsumables;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class ShippingLicenseSlot extends ZwSlotFrame
   {
      
      private var m_worldLabel:ZwTextField;
      
      private var m_worldCaption:ZwTextField;
      
      private var m_availabilityLabel:ZwTextField;
      
      private var m_buyBtn:GenericFarmCashButton;
      
      private var m_licenseItem:FarmItem;
      
      private var m_iconHolder:FarmIcon;
      
      public function ShippingLicenseSlot(element:MovieClip)
      {
         super(element);
         this.m_worldLabel = addWidget(new ZwTextField(element.worldLabel_tf)) as ZwTextField;
         this.m_worldCaption = addWidget(new ZwTextField(element.worldCaption_tf)) as ZwTextField;
         this.m_availabilityLabel = addWidget(new ZwTextField(element.availabilityLabel_tf),false) as ZwTextField;
         this.m_buyBtn = new GenericFarmCashButton(element.buy_bt,this.onBuyClick);
         this.m_buyBtn.disabled = true;
         this.m_buyBtn.getButton().visible = false;
         this.m_iconHolder = addWidget(new FarmIcon(element.iconHolder_mc)) as FarmIcon;
      }
      
      override public function release() : void
      {
         this.m_worldLabel = null;
         this.m_availabilityLabel = null;
         this.m_buyBtn.turnOff();
         this.m_buyBtn = null;
         this.m_licenseItem = null;
         this.m_iconHolder = null;
      }
      
      protected function clear() : void
      {
         this.m_worldLabel.visible = false;
         this.m_iconHolder.visible = false;
         this.m_worldCaption.visible = false;
         this.m_availabilityLabel.visible = false;
         this.m_buyBtn.getButton().visible = false;
         this.m_buyBtn.disabled = true;
      }
      
      override public function populate(data:Object) : void
      {
         var captionText:String = null;
         this.clear();
         this.m_worldLabel.text = data.friendlyName;
         this.m_worldLabel.visible = true;
         this.m_iconHolder.loadIcon(data.iconUrl);
         this.m_iconHolder.visible = true;
         if(Boolean(data.hasLicense) || Global.player.getSeenSessionFlag(data.itemName))
         {
            this.m_availabilityLabel.text = "Owned";
            this.m_availabilityLabel.visible = true;
         }
         else if(data.itemName)
         {
            this.m_licenseItem = Global.farmGameSettingsManager.getFarmItemByName(data.itemName);
            if(this.m_licenseItem != null)
            {
               this.m_buyBtn.getButton().visible = true;
               this.m_buyBtn.disabled = false;
               this.m_buyBtn.cost = this.m_licenseItem.realCashCost.toString();
               this.m_worldCaption.visible = true;
               captionText = "";
               if(Global.experimentManager.getExperimentVariant("fv_upgradeaward_" + data.type) == 0)
               {
                  captionText = ZLocUtils.t("Dialogs",data.type + "_Subtitle_ComingSoon");
               }
               else
               {
                  captionText = ZLocUtils.t("Dialogs",data.type + "_Subtitle");
               }
               this.m_worldCaption.text = captionText;
            }
         }
         else
         {
            this.m_availabilityLabel.text = "Coming Soon";
            this.m_availabilityLabel.visible = true;
         }
      }
      
      public function onBuyClick(event:Event = null) : void
      {
         if(!Global.player.canBuyItem(null,false,this.m_licenseItem,0,"",false))
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_licenseItem.cash,this.m_licenseItem.type);
         }
         else
         {
            this.m_buyBtn.disabled;
            Global.player.setSeenSessionFlag(this.m_licenseItem.name);
            dispatchEvent(new Event(Event.CLOSE,false,false));
            TransactionManager.addTransaction(new TBuyConsumables(this.m_licenseItem.name,false,{"displayBuyMessage":false}));
         }
      }
   }
}

