package Widgets.Frames.CreditsBuilding
{
   import Classes.Constants.MFSConstants;
   import Classes.RewardCreditsBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemType;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureTrackingManager;
   import Managers.MFSRequestManager;
   import Transactions.TGenericWorldObjectTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class ProgressPreviewSlot extends ZwSlotFrame
   {
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      private var m_data:Object;
      
      private var m_itemTitle:ZwTextField;
      
      protected var m_flyoutMc:MovieClip = null;
      
      private var m_building:RewardCreditsBuilding;
      
      private var m_window:RewardCreditsWindow;
      
      private var m_priceTextField:ZwTextField;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_redeemCallback:Function;
      
      private var m_whatIsThis:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_singleClickCallback:Function;
      
      private var m_redeemText:ZwTextField = null;
      
      private var m_needText:ZwTextField = null;
      
      private var m_farmCashText:ZwTextField = null;
      
      private var m_farmCashText2:ZwTextField = null;
      
      private var m_walletAmount:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_directPurchase:ZwFrame = null;
      
      private var m_directPurchase2:ZwFrame = null;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_firstCreditType:String = "";
      
      public function ProgressPreviewSlot(element:DisplayObject, redeemCallback:Function, building:RewardCreditsBuilding, window:RewardCreditsWindow, featureName:String = null, singleClickCallback:Function = null)
      {
         this.m_building = building;
         this.m_window = window;
         this.m_redeemCallback = redeemCallback;
         this.m_featureName = featureName ? featureName : "RewardCredits";
         this.m_singleClickCallback = singleClickCallback;
         super(element);
         if(m_element.itemTitle_tf)
         {
            this.m_itemTitle = addWidget(new ZwTextField(m_element.itemTitle_tf)) as ZwTextField;
         }
         var index:int = 0;
         var elementName:String = "itemAmount" + RewardCreditsWindow.getMcNumFromIndex(index) + "_tf";
         while(m_element[elementName])
         {
            addWidget(new ZwTextField(m_element[elementName]));
            index++;
            elementName = "itemAmount" + RewardCreditsWindow.getMcNumFromIndex(index) + "_tf";
         }
         if(m_element.treat2_mc)
         {
            (m_element.treat2_mc as MovieClip).visible = true;
            if(m_element.treat2_mc.treat2rollover_mc)
            {
               this.setRolloverText(m_element.treat2_mc.treat2rollover_mc);
               this.m_flyoutMc = m_element.treat2_mc.treat2rollover_mc;
               this.m_flyoutMc.visible = false;
               (m_element.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OVER,this.rolloverCallback);
               (m_element.treat2_mc as MovieClip).addEventListener(MouseEvent.ROLL_OUT,this.rolloutCallback);
            }
         }
         if(Boolean(m_element.redeem_mc) && Boolean(m_element.redeem_mc.redeem_tf))
         {
            this.m_redeemText = addWidget(new ZwTextField(m_element.redeem_mc.redeem_tf),false) as ZwTextField;
         }
         if(Boolean(m_element.proratedPurchase_mc) && Boolean(m_element.proratedPurchase_mc.need_tf))
         {
            this.m_needText = addWidget(new ZwTextField(m_element.proratedPurchase_mc.need_tf),false) as ZwTextField;
         }
         if(m_element.treat_mc)
         {
            (m_element.treat_mc as MovieClip).visible = true;
         }
         if(Boolean(m_element.directPurchase_mc) && Boolean(m_element.directPurchase_mc.farmCash_tf))
         {
            this.m_directPurchase = new ZwFrame(m_element.directPurchase_mc);
            this.m_farmCashText = this.m_directPurchase.addWidget(new ZwTextField(m_element.directPurchase_mc.farmCash_tf),false) as ZwTextField;
         }
         if(Boolean(m_element.directPurchase2_mc) && Boolean(m_element.directPurchase2_mc.farmCash_tf))
         {
            this.m_directPurchase2 = new ZwFrame(m_element.directPurchase2_mc);
            this.m_farmCashText2 = this.m_directPurchase2.addWidget(new ZwTextField(m_element.directPurchase2_mc.farmCash_tf),false) as ZwTextField;
         }
         if(Boolean(m_element.directPurchase_mc) && Boolean(m_element.directPurchase_mc.walletAmount_tf))
         {
            this.m_walletAmount = addWidget(new ZwTextField(m_element.directPurchase_mc.walletAmount_tf),false) as ZwTextField;
         }
         if(m_element.checkMark_mc)
         {
            this.m_checkMark = m_element.checkMark_mc as MovieClip;
         }
      }
      
      private function setRolloverText(element:DisplayObject) : void
      {
         var obj:Object = element as Object;
         if(obj.treat2rollover_tf)
         {
            obj.treat2rollover_tf.text = ZLocUtils.t("Dialogs",this.m_building.getCreditsFeatureName() + "_rollover_text");
         }
      }
      
      protected function rolloverCallback(event:MouseEvent) : void
      {
         this.m_flyoutMc.visible = true;
      }
      
      protected function rolloutCallback(event:MouseEvent) : void
      {
         this.m_flyoutMc.visible = false;
      }
      
      override public function populate(data:Object) : void
      {
         var farmItem:FarmItem = null;
         var firstCreditType:String = null;
         var creditType:String = null;
         var creditTypes:Array = null;
         var elementName:String = null;
         var costField:ZwTextField = null;
         var redeemItem:Object = null;
         var iconMC:MovieClip = null;
         var index:int = 0;
         var usedTypes:int = 0;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_objectPreviewFrame != null)
            {
               removeWidget(this.m_objectPreviewFrame);
               this.m_objectPreviewFrame = null;
            }
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
            if(Boolean(farmItem) && Boolean(m_element["icon_mc"]))
            {
               redeemItem = this.m_building.getRedeemItemByName(farmItem.name);
               iconMC = m_element.icon_mc;
               iconMC.filters = [];
               this.m_objectPreviewFrame = new ObjectPreviewFrame(iconMC,farmItem,null,[this.getZoomLevel(farmItem,redeemItem)],null,"","",null,new Point(redeemItem.horizontalOffset,redeemItem.verticalOffset));
               addWidget(this.m_objectPreviewFrame,true);
            }
            if(this.m_data.friendlyName)
            {
               this.m_itemTitle.text = ZLocUtils.tk_pk_asTitle(this.m_data.friendlyName);
               this.m_itemTitle.visible = true;
            }
            firstCreditType = "";
            var _loc12_:int = 0;
            var _loc13_:* = this.m_data.cost;
            for(creditType in _loc13_)
            {
               firstCreditType = creditType;
               this.m_firstCreditType = creditType;
            }
            creditTypes = this.m_data.creditTypes;
            if(creditTypes.length < 2)
            {
               elementName = "itemAmount" + RewardCreditsWindow.getMcNumFromIndex(usedTypes) + "_tf";
               costField = getWidget(m_element[elementName]) as ZwTextField;
               if(costField)
               {
                  costField.text = this.m_data.cost[firstCreditType];
                  costField.visible = true;
               }
            }
            else
            {
               usedTypes = 0;
               for(index = 0; index < creditTypes.length; index++)
               {
                  elementName = "itemAmount" + RewardCreditsWindow.getMcNumFromIndex(usedTypes) + "_tf";
                  if(Boolean(m_element[elementName]) && Boolean(this.m_data.cost[creditTypes[index]]))
                  {
                     costField = getWidget(m_element[elementName]) as ZwTextField;
                     if(costField)
                     {
                        costField.text = this.m_data.cost[creditTypes[index]];
                        costField.visible = true;
                        this.m_firstCreditType = firstCreditType;
                        usedTypes++;
                     }
                  }
               }
            }
            this.m_data.creditCostInfo = this.m_building.getRedeemItemCostInfo(this.m_data.cost);
            if(this.m_data.creditCostInfo.canAfford)
            {
               this.setRedeemState();
            }
            else
            {
               this.setBuyableState();
            }
         }
      }
      
      private function setRedeemState() : void
      {
         var str:String = "";
         if(Boolean(m_element.redeem_mc) && !this.isInDirectPurchaseExperiment())
         {
            (m_element.proratedPurchase_mc as MovieClip).visible = false;
            (m_element.redeem_mc as MovieClip).visible = true;
            if(m_element.redeem_mc.redeem_bt)
            {
               removeWidget(m_element.redeem_mc.redeem_bt);
               str = ZLocUtils.t(this.m_featureName,"Redeem");
               addWidget(new FarmAnimatedTextButton(m_element.redeem_mc.redeem_bt,str,this.onRedeemButtonClick));
            }
            if(m_element.redeem_mc.redeem_tf)
            {
               this.m_redeemText.text = ZLocUtils.t(this.m_featureName,"RedeemText",{"quantity":this.m_data.creditCostInfo.totalCreditCost});
               this.m_redeemText.visible = true;
            }
         }
         else if(m_element.directPurchase2_mc)
         {
            if(m_element["directPurchase_mc"])
            {
               (m_element.directPurchase_mc as MovieClip).visible = false;
            }
            (m_element.directPurchase2_mc as MovieClip).visible = true;
            if(m_element.directPurchase2_mc.redeem_bt)
            {
               removeWidget(m_element.directPurchase2_mc.redeem_bt);
               str = ZLocUtils.t(this.m_featureName,"Redeem");
               addWidget(new FarmAnimatedTextButton(m_element.directPurchase2_mc.redeem_bt,str,this.onRedeemButtonClick));
            }
            if(m_element.directPurchase2_mc.buy_bt)
            {
               removeWidget(m_element.directPurchase2_mc.buy_bt);
               str = ZLocUtils.t(this.m_featureName,"Buy");
               addWidget(new FarmAnimatedTextButton(m_element.directPurchase2_mc.buy_bt,str,this.onMarketBuy,true));
            }
            if(m_element.directPurchase2_mc.farmCash_tf)
            {
               this.m_farmCashText2.text = this.getItem().cash.toString();
               this.m_farmCashText2.visible = true;
            }
         }
      }
      
      private function setBuyableState() : void
      {
         var endTime:Number = NaN;
         var proratedBtn:FarmAnimatedTextButton = null;
         var directBtn:FarmAnimatedTextButton = null;
         var str:String = "";
         var amount:int = int(this.m_data.creditCostInfo.costToComplete);
         var askEnabled:Boolean = true;
         var disableDate:String = Global.farmGameSettingsManager.getString(this.m_featureName + "AskSendDisableDate");
         if(disableDate.length > 0)
         {
            endTime = FarmGameUtil.synchronizedDateToNumber(disableDate);
            askEnabled = GlobalEngine.serverTime <= endTime;
         }
         if(Boolean(m_element.proratedPurchase_mc) && !this.isInDirectPurchaseExperiment())
         {
            (m_element.proratedPurchase_mc as MovieClip).visible = true;
            if(m_element.proratedPurchase_mc.ask_bt)
            {
               removeWidget(m_element.proratedPurchase_mc.ask_bt);
               if(askEnabled)
               {
                  proratedBtn = addWidget(new FarmAnimatedTextButton(m_element.proratedPurchase_mc.ask_bt,str,this.generateAskForCreditsCallback(),true)) as FarmAnimatedTextButton;
                  this.checkAskButtonGrayOutStatus(proratedBtn);
               }
            }
            if(m_element.proratedPurchase_mc.buy_bt)
            {
               removeWidget(m_element.proratedPurchase_mc.buy_bt);
               str = ZLocUtils.t(this.m_featureName,"ProratedCost",{"quantity":amount});
               addWidget(new FarmAnimatedTextButton(m_element.proratedPurchase_mc.buy_bt,str,this.onBuyButtonClick,true)) as FarmAnimatedTextButton;
            }
            if(m_element.proratedPurchase_mc.need_tf)
            {
               this.m_needText.text = ZLocUtils.t(this.m_featureName,"NeedText",{"quantity":amount});
               this.m_needText.visible = true;
            }
         }
         else if(m_element.directPurchase_mc)
         {
            (m_element.directPurchase_mc as MovieClip).visible = true;
            if(m_element.directPurchase_mc.ask_bt)
            {
               removeWidget(m_element.directPurchase_mc.ask_bt);
               if(askEnabled)
               {
                  directBtn = addWidget(new FarmAnimatedTextButton(m_element.directPurchase_mc.ask_bt,str,this.generateAskForCreditsCallback(),true)) as FarmAnimatedTextButton;
                  this.checkAskButtonGrayOutStatus(directBtn);
               }
            }
            if(m_element.directPurchase_mc.buy_bt)
            {
               removeWidget(m_element.directPurchase_mc.buy_bt);
               str = ZLocUtils.t(this.m_featureName,"Buy");
               addWidget(new FarmAnimatedTextButton(m_element.directPurchase_mc.buy_bt,str,this.onMarketBuy,true)) as FarmAnimatedTextButton;
            }
            if(m_element.directPurchase_mc.farmCash_tf)
            {
               this.m_farmCashText.text = this.getItem().cash.toString();
               this.m_farmCashText.visible = true;
            }
            if(this.m_walletAmount != null)
            {
               this.m_walletAmount.text = amount.toString();
               this.m_walletAmount.visible = false;
            }
         }
      }
      
      private function checkAskButtonGrayOutStatus(askButton:FarmAnimatedTextButton) : void
      {
         var askStr:String = ZLocUtils.t_pk(RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Ask"));
         var waitStr:String = ZLocUtils.t_pk(RewardCreditsBuilding.getLocalizedKey(this.m_featureName,"Waiting"));
         if(!this.m_building.isAllowedToSendR4R() && (this.m_window.m_disableFeedPosts == true || !this.m_building.isOutsideAskPostFeedThrottle() || !this.m_building.isAllowedToPostAskFeed(this.m_firstCreditType)))
         {
            askButton.enabled = false;
            askButton.text = waitStr;
            askButton.applyGrayOut = true;
         }
         else
         {
            askButton.enabled = true;
            askButton.text = askStr;
            askButton.applyGrayOut = false;
         }
      }
      
      private function isInDirectPurchaseExperiment() : Boolean
      {
         var result:Boolean = false;
         var expName:String = "fv_" + this.m_featureName + "_direct_purchase";
         if(Global.experimentManager.getExperimentVariant(expName) == 1 || Global.experimentManager.getExperimentVariant(expName) == 2)
         {
            result = true;
         }
         return result;
      }
      
      private function onAskForCredits(event:MouseEvent) : void
      {
         MFSRequestManager.getInstance().makeAskCreditsRequest(this.m_featureName,MFSConstants.SOURCE_UI,this.m_featureName,"request_more_credits","",this.m_firstCreditType);
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         if(this.m_singleClickCallback != null && Boolean(this.m_data))
         {
            if(this.m_singleClickCallback(this.m_data))
            {
               this.showCheckMark();
            }
         }
      }
      
      private function generateAskForCreditsCallback(creditType:String = null) : Function
      {
         return function(event:Event):void
         {
            var directAskButton:* = undefined;
            var proratedAskButton:* = undefined;
            m_window.m_disableFeedPosts = true;
            m_window.refreshWindow();
            if(Boolean(m_element) && Boolean(m_element.directPurchase_mc))
            {
               if(m_element.directPurchase_mc.ask_bt)
               {
                  directAskButton = getWidget(m_element.directPurchase_mc.ask_bt) as FarmAnimatedTextButton;
                  checkAskButtonGrayOutStatus(directAskButton);
                  m_building.askForCredits(creditType,onAskButtonCompleteCallback);
               }
            }
            else if(Boolean(m_element) && Boolean(m_element.proratedPurchase_mc))
            {
               if(m_element.proratedPurchase_mc.ask_bt)
               {
                  proratedAskButton = getWidget(m_element.directPurchase_mc.ask_bt) as FarmAnimatedTextButton;
                  checkAskButtonGrayOutStatus(directAskButton);
                  m_building.askForCredits(creditType,onAskButtonCompleteCallback);
               }
            }
         };
      }
      
      private function onAskButtonCompleteCallback(result:Object = null) : void
      {
         var directAskButton:FarmAnimatedTextButton = null;
         var proratedAskButton:FarmAnimatedTextButton = null;
         if(Boolean(m_element) && Boolean(m_element.directPurchase_mc))
         {
            if(m_element.directPurchase_mc.ask_bt)
            {
               directAskButton = getWidget(m_element.directPurchase_mc.ask_bt) as FarmAnimatedTextButton;
               this.checkAskButtonGrayOutStatus(directAskButton);
            }
         }
         else if(Boolean(m_element) && Boolean(m_element.proratedPurchase_mc))
         {
            if(m_element.proratedPurchase_mc.ask_bt)
            {
               proratedAskButton = getWidget(m_element.directPurchase_mc.ask_bt) as FarmAnimatedTextButton;
               this.checkAskButtonGrayOutStatus(proratedAskButton);
            }
         }
         this.m_window.m_disableFeedPosts = false;
         this.m_window.refreshWindow();
      }
      
      private function onMarketBuy(event:MouseEvent) : void
      {
         var m_item:FarmItem = null;
         if(Global.player.canBuyCash(this.getItem().cash,false))
         {
            this.showCheckMark();
            m_item = this.getItem();
            TransactionManager.addTransaction(new TGenericWorldObjectTransaction(this.m_building,"buyItemPutGiftbox",null,[m_item.name]),true);
            if(m_item.realCashCost > 0)
            {
               Global.player.cash -= m_item.realCashCost;
               Global.player.addGift(m_item.name,"0",1);
               FeatureTrackingManager.instance.madePurchase(this.m_building.getCreditsFeatureName());
            }
            FarmStatsManager.count(this.m_featureName,this.getItem().name,this.getItem().cash.toString());
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",this.getItem().cash,this.getItem().type);
         }
      }
      
      private function showCheckMark() : void
      {
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = true;
            this.m_checkMark.gotoAndPlay(0);
            this.m_checkMark.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(this.m_checkMark != null && this.m_checkMark.currentFrame == this.m_checkMark.totalFrames)
         {
            this.m_checkMark.stop();
            this.m_checkMark.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_checkMark.visible = false;
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      private function onRedeemButtonClick(evt:Event) : void
      {
         if(this.m_redeemCallback != null && Boolean(this.m_data))
         {
            this.m_redeemCallback(this.m_data);
         }
      }
      
      private function getItem() : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
      }
      
      override public function release() : void
      {
         this.m_data = null;
         super.release();
      }
      
      private function getZoomLevel(farmItem:FarmItem, redeemItem:Object = null) : Number
      {
         var zoomLevel:Number = 0;
         if(farmItem != null && redeemItem != null && redeemItem.scale != 0)
         {
            zoomLevel = Number(redeemItem.scale);
         }
         else if(farmItem != null && farmItem.type != FarmItemType.TREE)
         {
            zoomLevel = farmItem.sizeX == 1 ? 2 : 1.5;
         }
         else
         {
            zoomLevel = 1.5;
         }
         return zoomLevel;
      }
   }
}

