package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.LicenseManager;
   import Transactions.TAcquireLicense;
   import Widgets.Constants.Market.Currency;
   import flash.events.MouseEvent;
   import flash.net.*;
   import flash.utils.Dictionary;
   
   public class Donate extends Dialog
   {
      
      private var m_accept:GenericButton;
      
      private var m_cancel:GenericButton;
      
      private var m_marketItem:XML;
      
      protected var m_item:FarmItem;
      
      protected var m_amount:Number;
      
      protected var m_buttons:Array = new Array();
      
      protected var m_licenseCodes:Dictionary = new Dictionary();
      
      public function Donate(item:XML, farmItem:FarmItem = null)
      {
         if(farmItem)
         {
            this.m_item = farmItem;
            this.m_marketItem = null;
         }
         else
         {
            this.m_marketItem = item;
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_marketItem.@name);
         }
         m_dialogAsset = "assets/dialogs/FV_SweetSeeds3_donate.swf";
         super(true);
      }
      
      override protected function onLoadComplete() : void
      {
         var licenseCode:String = null;
         var donationValue:Number = NaN;
         var donationValueStr:String = null;
         var donateIdx:int = 0;
         var gb:GenericButton = null;
         var costStr:String = null;
         var currencyType:String = null;
         var coinYield:int = 0;
         var plantXp:String = null;
         var growTime:Number = NaN;
         var donationArr:Array = null;
         var curObj:Object = null;
         var dayInSeconds:Number = NaN;
         super.onLoadComplete();
         m_window.sweetSeedsDonate_mc = m_window.getChildAt(0);
         this.m_licenseCodes = new Dictionary();
         if(!this.m_marketItem)
         {
            donationArr = this.m_item.getDonationArr();
            for(donateIdx = 0; donateIdx < donationArr.length; donateIdx++)
            {
               curObj = donationArr[donateIdx];
               licenseCode = curObj.name;
               donationValueStr = curObj.value;
               donationValue = Number(curObj.value);
               gb = new GenericButton(m_window.sweetSeedsDonate_mc["donate" + donateIdx + "_bt"],this.onAmountClick,donationValueStr,"gb" + donateIdx);
               gb.enableHitState(true);
               gb.text = donationValueStr;
               if(Boolean(curObj.defaultButton) && curObj.defaultButton == "true")
               {
                  gb.state = GenericButton.HITSTATE;
                  this.m_amount = donationValue;
               }
               else
               {
                  gb.state = GenericButton.UPSTATE;
               }
               this.m_buttons.push(gb);
               this.m_licenseCodes["SWEET_SEEDS_LICENSE_CODE_" + donationValue] = licenseCode;
            }
         }
         else
         {
            for(donateIdx = 0; donateIdx < this.m_marketItem.donation.length(); donateIdx++)
            {
               licenseCode = this.m_marketItem.donation[donateIdx].@name;
               donationValue = Number(this.m_marketItem.donation[donateIdx].@value);
               gb = new GenericButton(m_window.sweetSeedsDonate_mc["donate" + donateIdx + "_bt"],this.onAmountClick,donationValue.toString(),"gb" + donateIdx);
               gb.enableHitState(true);
               gb.text = donationValue.toString();
               if(Boolean(this.m_marketItem.donation[donateIdx].@defaultButton) && this.m_marketItem.donation[donateIdx].@defaultButton.toString() == "true")
               {
                  gb.state = GenericButton.HITSTATE;
                  this.m_amount = donationValue;
               }
               else
               {
                  gb.state = GenericButton.UPSTATE;
               }
               this.m_buttons.push(gb);
               this.m_licenseCodes["SWEET_SEEDS_LICENSE_CODE_" + donationValue] = this.m_marketItem.donation[donateIdx].@name;
            }
         }
         m_window.sweetSeedsDonate_mc.body0_tf.htmlText = ZLocUtils.t("Dialogs","InitInfo",{"link":GlobalEngine.getFlashVar("sn_app_url") + "seedsforhaiti.php"});
         m_window.sweetSeedsDonate_mc.body1_tf.htmlText = ZLocUtils.t("Dialogs","SweetBody1");
         var gb_moreinfo:GenericButton = new GenericButton(m_window.sweetSeedsDonate_mc.info_bt,this.onMoreInfoClick,GlobalEngine.getFlashVar("sn_app_url") + "seedsforhaiti.php","gb_moreinfo");
         gb_moreinfo.state = GenericButton.UPSTATE;
         gb_moreinfo.text = ZLocUtils.t("Dialogs","ClickHere");
         gb_moreinfo.m_overlay.buttonMode = true;
         m_window.sweetSeedsDonate_mc.cropTitle_tf.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         if(isInDataSourceExperiment)
         {
            currencyType = this.m_item.getStringFromDataSource("market");
            coinYield = this.m_item.getIntFromDataSource("coinYield");
            plantXp = this.m_item.getStringFromDataSource("plantXp");
            growTime = this.m_item.getNumberFromDataSource("growTime");
         }
         else
         {
            currencyType = this.m_item.xml.market.toString();
            coinYield = int(this.m_item.xml.coinYield);
            plantXp = this.m_item.xml.plantXp;
            growTime = Number(this.m_item.xml.growTime);
         }
         switch(currencyType)
         {
            case Currency.CASH:
               if(isInDataSourceExperiment)
               {
                  costStr = Utilities.formatNumber(this.m_item.getIntFromDataSource("cash"));
               }
               else
               {
                  costStr = Utilities.formatNumber(this.m_item.xml.cash);
               }
               break;
            case Currency.COINS:
            default:
               if(isInDataSourceExperiment)
               {
                  costStr = Utilities.formatNumber(this.m_item.getIntFromDataSource("cost"));
               }
               else
               {
                  costStr = Utilities.formatNumber(this.m_item.xml.cost);
               }
         }
         m_window.sweetSeedsDonate_mc.cost_tf.text = ZLocUtils.t("Dialogs","Cost",{
            "coinQuantity":costStr,
            "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",int(costStr))
         });
         m_window.sweetSeedsDonate_mc.sell_tf.text = ZLocUtils.t("Dialogs","Yield",{
            "quantity":coinYield,
            "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",coinYield)
         });
         m_window.sweetSeedsDonate_mc.xp_tf.text = ZLocUtils.t("Dialogs","SweetXPGained",{"quantity":plantXp});
         var harvestTime:Number = growTime;
         var harvestLocStr:String = "";
         var harvestLocObj:Object = {};
         if(harvestTime < 1)
         {
            dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
            harvestTime = dayInSeconds / 60 / 60 * harvestTime;
            harvestTime = int(harvestTime);
            harvestLocStr = "GrowthHours";
            harvestLocObj.quantity = harvestTime;
            harvestLocObj.Hour_word = ZLocUtils.tk("Dialogs","Hour_word","",harvestTime);
         }
         else
         {
            harvestLocStr = "GrowthDays";
            harvestLocObj.quantity = harvestTime;
            harvestLocObj.Day_word = ZLocUtils.tk("Dialogs","Day_word","",harvestTime);
         }
         m_window.sweetSeedsDonate_mc.harvest_tf.text = ZLocUtils.t("Dialogs",harvestLocStr,harvestLocObj);
         m_window.sweetSeedsDonate_mc.body3_tf.text = ZLocUtils.t("Dialogs","AskForDonation");
         FarmStatsManager.count("Donate","sweet_seeds");
         this.m_accept = new GenericButton(m_window.sweetSeedsDonate_mc.accept_bt,this.onOkClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","Accept");
         this.m_cancel = new GenericButton(m_window.sweetSeedsDonate_mc.cancel_bt,this.onCancelClick);
         this.m_cancel.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      private function onOkClick(event:MouseEvent) : void
      {
         var licenseCode:String = null;
         var name:String = null;
         FarmStatsManager.count("Donate","sweet_seeds","accept");
         FarmStatsManager.count("Donate","sweet_seeds","accept","" + this.m_amount);
         var cash:int = this.m_amount;
         var isInDataSourceExperiment:Boolean = !this.m_marketItem;
         if(Global.player.canBuyCash(cash,false))
         {
            if(isInDataSourceExperiment)
            {
               if(!LicenseManager.getInstance().hasCurrentLicense(this.m_item.code))
               {
                  licenseCode = this.m_licenseCodes["SWEET_SEEDS_LICENSE_CODE_" + this.m_amount];
                  TransactionManager.addTransaction(new TAcquireLicense(null,licenseCode,this.onLicenseGranted,this.m_item.name));
               }
            }
            else if(!LicenseManager.getInstance().hasCurrentLicense(this.m_marketItem.@code))
            {
               licenseCode = this.m_licenseCodes["SWEET_SEEDS_LICENSE_CODE_" + this.m_amount];
               TransactionManager.addTransaction(new TAcquireLicense(this.m_marketItem,licenseCode,this.onLicenseGranted));
            }
         }
         else
         {
            if(isInDataSourceExperiment)
            {
               name = this.m_item.name;
            }
            else
            {
               name = this.m_marketItem.name();
            }
            UI.displayMessage(ZLocUtils.t("Dialogs","BuyCashDialog"),GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyCash,"",true);
            FarmStatsManager.count("fv_cash_buy_fail",name,"view_popup");
         }
         event.stopPropagation();
         close();
      }
      
      private function onBuyCash(event:GenericPopupEvent) : void
      {
         var name:String = null;
         if(!this.m_marketItem)
         {
            name = this.m_item.name;
         }
         else
         {
            name = this.m_marketItem.name();
         }
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count("fv_cash_buy_fail",name,"click_accept");
         }
         else
         {
            FarmStatsManager.count("fv_cash_buy_fail",name,"click_cancel");
         }
      }
      
      private function onCancelClick(event:MouseEvent) : void
      {
         var name:String = null;
         FarmStatsManager.count("Donate","sweet_seeds","cancel");
         event.stopPropagation();
         close();
         if(!this.m_marketItem)
         {
            name = this.m_item.name;
         }
         else
         {
            name = this.m_marketItem.name();
         }
         FarmStatsManager.count("sweet_seeds_haiti",name,"cancelled");
         UI.displayMarketDialog("cancelDonateSweetSeeds");
      }
      
      protected function onAmountClick(event:MouseEvent) : void
      {
         var gb:GenericButton = null;
         gb = event.currentTarget.buttonPointer;
         this.m_amount = parseInt(event.currentTarget.buttonValue);
         this.m_buttons.forEach(function(element:GenericButton, indx:Number, arr:Array):void
         {
            if(element == gb)
            {
               element.state = GenericButton.HITSTATE;
            }
            else
            {
               element.state = GenericButton.UPSTATE;
            }
         });
      }
      
      protected function onMoreInfoClick(e:MouseEvent) : void
      {
         var url:String = e.currentTarget.buttonValue;
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      public function onLicenseGranted(result:Object) : void
      {
         if(result)
         {
            Global.player.cash -= this.m_amount;
            Global.player.addGift(result.gift);
            UI.displayPopup(new SweetSeedsThanks(this.m_item.name,result.friendRewardName,result.friendRewardLink),false);
         }
      }
   }
}

