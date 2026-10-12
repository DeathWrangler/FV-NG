package Widgets.Windows.Charity
{
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class DonateWindow extends FarmWindow
   {
      
      public static const SOURCE_MARKET:String = "martket_card";
      
      public static const SOURCE_MOTD:String = "motd";
      
      protected var m_featureName:String;
      
      protected var m_seedItem:SeedItem;
      
      protected var m_onAcceptCallback:Function = null;
      
      protected var m_windowSource:String = null;
      
      protected var m_mainFrame:ZwFrame = null;
      
      private var m_donateAmount:Number = 0;
      
      public function DonateWindow(seedData:SeedItem = null, onAcceptCallback:Function = null, source:String = null, featureName:String = null)
      {
         this.m_featureName = featureName;
         this.m_seedItem = seedData;
         this.m_onAcceptCallback = onAcceptCallback;
         this.m_windowSource = source;
         if(this.m_seedItem)
         {
            this.name = "DonateWindow" + this.m_seedItem.name;
            FarmStatsManager.count("charity_" + seedData.name,"purchase_dialog_viewed",source);
         }
         else if(this.m_featureName)
         {
            this.name = "DonateWindow" + this.m_featureName;
            FarmStatsManager.count(this.m_windowSource,"impressions",this.m_featureName);
         }
         super(this.getDialogAssetURL());
      }
      
      protected function getDialogAssetURL() : String
      {
         var assetURL:String = null;
         if(this.m_seedItem)
         {
            assetURL = "assets/dialogs/FV_Campaign_" + this.m_seedItem.name + ".swf";
         }
         else if(this.m_featureName)
         {
            assetURL = "assets/dialogs/FV_" + this.m_featureName + ".swf";
         }
         return assetURL;
      }
      
      protected function get donateAmount() : int
      {
         return this.m_donateAmount;
      }
      
      override protected function postLoadComplete() : void
      {
         var harvestTime:Number = NaN;
         var harvestLocStr:String = null;
         var harvestLocObj:Object = null;
         var donations:Array = null;
         var donateIdx:int = 0;
         var dayInSeconds:Number = NaN;
         var donationObj:Object = null;
         var licenseCode:String = null;
         var donationValue:Number = NaN;
         var donateBt:FarmAnimatedTextButton = null;
         super.postLoadComplete();
         if(this.m_seedItem)
         {
            this.m_mainFrame = addWidget(new ZwFrame(m_window.mainDonate_mc)) as ZwFrame;
            this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.mainDonate_mc.accept_bt,this.onAccept));
            if(m_window.mainDonate_mc.hasOwnProperty("cancel_bt"))
            {
               this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.mainDonate_mc.cancel_bt,this.onClose));
            }
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.cropTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_seedItem.friendlyName)));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.cost_tf,ZLocUtils.t("Dialogs","Cost",{
               "coinQuantity":this.m_seedItem.cost,
               "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",int(this.m_seedItem.cost))
            })));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.sell_tf,ZLocUtils.t("Dialogs","Yield",{"coinQuantity":this.m_seedItem.coinYield.toString()})));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.xp_tf,ZLocUtils.t("Dialogs","SeedXPGained",{"quantity":this.m_seedItem.plantXp.toString()})));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.body0_tf,ZLocUtils.t("Dialogs","Campaign_DonateBody0_" + this.m_seedItem.name)));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.body3_tf,ZLocUtils.t("Dialogs","Campaign_DonateBody3_" + this.m_seedItem.name)));
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.body1_tf,ZLocUtils.t("Dialogs","Campaign_DonateBody1_" + this.m_seedItem.name)));
            this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.mainDonate_mc.info_bt,ZLocUtils.t("Dialogs","Campaign_ClickHereText_" + this.m_seedItem.name),this.onMoreInfoClick));
            harvestTime = this.m_seedItem.growTime;
            harvestLocStr = "";
            harvestLocObj = {};
            if(harvestTime < 1)
            {
               dayInSeconds = Global.farmGameSettingsManager.getNumber("inGameDaySeconds");
               harvestTime = dayInSeconds / 60 / 60 * harvestTime;
               harvestLocStr = "GrowthHours";
               harvestLocObj.Hour_word = ZLocUtils.tk("Dialogs","Hour_word","",harvestTime);
            }
            else
            {
               harvestLocStr = "GrowthDays";
               harvestLocObj.Day_word = ZLocUtils.tk("Dialogs","Day_word","",harvestTime);
            }
            harvestLocObj.quantity = int(harvestTime);
            this.m_mainFrame.addWidget(new ZwTextField(m_window.mainDonate_mc.harvest_tf,ZLocUtils.t("Dialogs",harvestLocStr,harvestLocObj)));
            donations = this.m_seedItem.donations;
            for(donateIdx = 0; donateIdx < donations.length; donateIdx++)
            {
               donationObj = donations[donateIdx];
               licenseCode = donationObj.licenseCode;
               donationValue = Number(donationObj.donationValue);
               donateBt = new FarmAnimatedTextButton(m_window.mainDonate_mc["donate" + donateIdx + "_bt"],this.getDonateAmountText(donationValue),this.onAmountClick);
               donateBt.element.checkmark_mc.visible = false;
               this.m_mainFrame.addWidget(donateBt);
            }
         }
      }
      
      protected function getDonateAmountText(value:Number) : String
      {
         return value.toString();
      }
      
      protected function onMoreInfoClick(e:MouseEvent) : void
      {
         var url:String = ZLocUtils.t("Dialogs","Campaign_ClickHereURL_" + this.m_seedItem.name);
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      protected function onAmountClick(event:Event) : void
      {
         var donations:Array = null;
         var donateIdx:int = 0;
         var donationObj:Object = null;
         var donateBt:FarmAnimatedTextButton = null;
         var clickedButton:FarmAnimatedTextButton = this.m_mainFrame.getWidget(event.currentTarget) as FarmAnimatedTextButton;
         if(clickedButton != null)
         {
            donations = this.m_seedItem.donations;
            for(donateIdx = 0; donateIdx < donations.length; donateIdx++)
            {
               donationObj = donations[donateIdx];
               donateBt = this.m_mainFrame.getWidget(m_window.mainDonate_mc["donate" + donateIdx + "_bt"]) as FarmAnimatedTextButton;
               if(donateBt)
               {
                  if(donateBt == clickedButton)
                  {
                     this.m_donateAmount = donationObj.donationValue;
                     donateBt.element.checkmark_mc.visible = true;
                  }
                  else
                  {
                     donateBt.element.checkmark_mc.visible = false;
                  }
               }
            }
         }
      }
      
      private function onAccept(event:Event) : void
      {
         var donations:Array = null;
         var code:String = null;
         var donationObj:Object = null;
         if(this.m_donateAmount > 0)
         {
            donations = this.m_seedItem.donations;
            code = null;
            for each(donationObj in donations)
            {
               if(donationObj.donationValue == this.donateAmount)
               {
                  code = donationObj.licenseCode;
                  break;
               }
            }
            if(code)
            {
               GlobalEngine.info("Donate","Calling onDonate(\'" + code + "\')");
               this.onDonate(code);
            }
            else
            {
               ErrorManager.addError("Failed to find donation entry");
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Campaign_DonateNoAmount_" + this.m_seedItem.name),GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      protected function onDonate(code:String) : void
      {
         if(this.m_windowSource == SOURCE_MARKET)
         {
            UI.closeMarketDialog();
         }
         if(this.m_onAcceptCallback != null)
         {
            this.m_onAcceptCallback();
            this.m_onAcceptCallback = null;
         }
         FarmStatsManager.count("charity_" + this.m_seedItem.name,"purchase_dialog_action","donate");
         FarmStatsManager.count("charity_" + this.m_seedItem.name,"donation_selected",this.donateAmount.toString());
         close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_onAcceptCallback != null)
         {
            this.m_onAcceptCallback();
         }
         if(this.m_seedItem)
         {
            FarmStatsManager.count("charity_" + this.m_seedItem.name,"purchase_dialog_action","cancel");
         }
         else
         {
            FarmStatsManager.count(this.m_windowSource,"close",this.m_featureName);
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_mainFrame = null;
      }
   }
}

