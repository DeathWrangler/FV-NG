package Widgets.Windows.Market
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class MarketBuyBerryLicenseWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 50;
      
      protected var m_item:FarmItem = null;
      
      private var m_acceptCallback:Function;
      
      private var m_cancelCallback:Function;
      
      public function MarketBuyBerryLicenseWindow(item:FarmItem, acceptCallback:Function, cancelCallback:Function)
      {
         this.m_item = item;
         this.m_acceptCallback = acceptCallback;
         this.m_cancelCallback = cancelCallback;
         super("assets/dialogs/FV_BerryCrop.swf",true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var header:ZwFrame = addWidget(new ZwFrame(m_window.header_mc)) as ZwFrame;
         header.addWidget(new ZwTextField(m_window.header_mc.title_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         header.addWidget(new ZwTextField(m_window.header_mc.info_tf,this.getItemInfoText(),true));
         var icon:FarmIcon = addWidget(new FarmIcon(m_window.header_mc.icon_mc,this.m_item.iconUrl)) as FarmIcon;
         icon.setIconSize(ICON_SIZE,ICON_SIZE);
         var license:XML = Global.farmGameSettingsManager.getLicenseXML(this.m_item.license);
         var licenseEndDate:String = String(license.endDate);
         var licenseDuration:Number = Number(license.duration);
         var licenseTimeLeft:Number = licenseDuration * 24 * 60 * 60;
         var licenseTitle:String = licenseDuration / 7 == Math.round(licenseDuration / 7) ? ZLocUtils.t("Dialogs","MarketBuyCashLicense_LicenseTitleWeek",{"quantity":licenseDuration / 7}) : ZLocUtils.t("Dialogs","MarketBuyCashLicense_LicenseTitleDay",{"quantity":licenseDuration});
         var formattedLicenseDuration:String = FarmGameUtil.toFriendlyTime(licenseTimeLeft);
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","MarketBuyCashLicense_Details",{
            "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
            "dateStr":licenseEndDate
         })));
         var slot:ZwFrame = addWidget(new ZwFrame(m_window.slot_0_mc)) as ZwFrame;
         slot.addWidget(new ZwTextField(m_window.slot_0_mc.title_tf,licenseTitle));
         slot.addWidget(new ZwTextField(m_window.slot_0_mc.generic_tf,ZLocUtils.t("Dialogs","MarketBuyCashLicense_LicenseDuration",{"timeStr":formattedLicenseDuration})));
         slot.addWidget(new ZwTextField(m_window.slot_0_mc.amount_tf,String(this.m_item.licenseCost)));
         var m_berryIcon:ZwWidget = addWidget(new ZwWidget(m_window.slot_0_mc.berryIcon_mc)) as ZwWidget;
         m_berryIcon.visible = true;
         var cashButton:FarmAnimatedTextButton = slot.addWidget(new FarmAnimatedTextButton(m_window.slot_0_mc.redeem_bt,ZLocUtils.t("Dialogs","MarketCardRedeemButton"),this.onBuyButtonClick)) as FarmAnimatedTextButton;
         if(!Global.player.canBuyWithCurrency("berry",this.m_item.licenseCost))
         {
            cashButton.enabled = false;
         }
         var xpBoost:ZwFrame = addWidget(new ZwFrame(m_window.burstXP_mc)) as ZwFrame;
         xpBoost.addWidget(new ZwTextField(m_window.burstXP_mc.generic_0_tf,ZLocUtils.t("FarmVille","XP")));
         xpBoost.addWidget(new ZwTextField(m_window.burstXP_mc.generic_1_tf,ZLocUtils.t("Dialogs","MarketBuyCashLicense_Boost")));
         var coinBoost:ZwFrame = addWidget(new ZwFrame(m_window.burstCoin_mc)) as ZwFrame;
         coinBoost.addWidget(new ZwTextField(m_window.burstCoin_mc.generic_0_tf,ZLocUtils.t("FarmVille","Coin").toLocaleUpperCase()));
         coinBoost.addWidget(new ZwTextField(m_window.burstCoin_mc.generic_1_tf,ZLocUtils.t("Dialogs","MarketBuyCashLicense_Boost")));
      }
      
      private function getItemInfoText() : String
      {
         var coinYield:int = 0;
         var growTime:Number = NaN;
         var dayInSeconds:Number = NaN;
         var info:Array = [];
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            coinYield = this.m_item.getIntFromDataSource("coinYield");
            growTime = this.m_item.getNumberFromDataSource("growTime");
         }
         else
         {
            coinYield = int(this.m_item.xml.coinYield);
            growTime = Number(this.m_item.xml.growTime);
         }
         info.push(ZLocUtils.t("Dialogs","Yield",{
            "coinQuantity":coinYield,
            "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",coinYield)
         }));
         var harvestTime:Number = growTime;
         var harvestLocStr:String = "";
         var harvestLocObj:Object = {};
         if(harvestTime < 1)
         {
            dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
            harvestTime = dayInSeconds / 60 / 60 * harvestTime;
            harvestLocStr = "GrowthHours";
            harvestLocObj.quantity = Math.floor(harvestTime);
            harvestLocObj.Hour_word = ZLocUtils.tk("Dialogs","Hour_word","",harvestLocObj.quantity);
         }
         else
         {
            harvestLocStr = "GrowthDays";
            harvestLocObj.quantity = harvestTime;
            harvestLocObj.Day_word = ZLocUtils.tk("Dialogs","Day_word","",harvestLocObj.quantity);
         }
         info.push(ZLocUtils.t("Dialogs",harvestLocStr,harvestLocObj));
         info.push(ZLocUtils.t("Dialogs","XPGained",{"quantity":this.m_item.plantXp}));
         return info.join("\n");
      }
      
      private function onBuyButtonClick(event:Event) : void
      {
         if(this.m_acceptCallback != null)
         {
            this.m_acceptCallback(this.m_item);
         }
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_cancelCallback != null)
         {
            this.m_cancelCallback();
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_item = null;
         this.m_acceptCallback = null;
         this.m_cancelCallback = null;
         super.release();
      }
   }
}

