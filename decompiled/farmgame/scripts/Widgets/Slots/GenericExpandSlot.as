package Widgets.Slots
{
   import Classes.BuildingItemUseMediator;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.IExpandComponent;
   import Classes.ImageLoader;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.InGamePaymentsManager;
   import Managers.MFSRequestManager;
   import Managers.TemplateUIUtility;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.WishingFountainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GenericExpandSlot extends ZwSlotFrame
   {
      
      private var m_data:Object = null;
      
      private var m_dataItem:FarmItem = null;
      
      private var m_parentWindow:FarmWindow = null;
      
      private var m_building:StorageBuilding = null;
      
      protected var m_cashNeeded:int = 0;
      
      protected var m_itemFrame:ZwWidget = null;
      
      protected var m_frictionlessBuy:Boolean = false;
      
      protected var m_frictionlessPrice:ZwBaseWidget = null;
      
      protected var m_priceMultiplier:Number;
      
      protected var m_forceFrictionless:Boolean = false;
      
      protected var m_completeNowWidget:ZwBaseWidget = null;
      
      protected var m_expandComponent:IExpandComponent = null;
      
      protected var m_featureBuilding:FeatureBuilding = null;
      
      private var m_waitingFeedCallback:Boolean = false;
      
      private var m_title:ZwTextField = null;
      
      private var m_alive:ZwTextField = null;
      
      private const MC_SLOT:String = "mc_Slot_V_0";
      
      private var m_slotBGIcon:DisplayObject;
      
      public function GenericExpandSlot(element:DisplayObject, parentWindow:FarmWindow, building:StorageBuilding, expandComponent:IExpandComponent, forceFrictionless:Boolean = false)
      {
         var priceMovieClip:MovieClip = null;
         var slot80BGPath:String = null;
         FarmStatsManager.sample(1000,"fv_fbml_depr_inspect","GenericExpandSlot","called");
         super(element);
         this.m_parentWindow = parentWindow;
         this.m_building = building;
         if(this.m_building is FeatureBuilding)
         {
            this.m_featureBuilding = this.m_building as FeatureBuilding;
         }
         this.m_expandComponent = expandComponent;
         addWidget(new ZwFrame(m_element.completeIcon_mc));
         if(m_element.itemFrame_mc != null)
         {
            this.m_itemFrame = addWidget(new ZwWidget(m_element.itemFrame_mc)) as ZwWidget;
         }
         addWidget(new ZwTextField(m_element.completeIcon_mc.completed_tf,ZLocUtils.t("Dialogs","GenericExpansion_completed_text")));
         if(Boolean(m_element.itemTitle_tf_new) && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.itemTitle_tf_new);
            this.m_title = addWidget(new ZwTextField(m_element.itemTitle_tf_new)) as ZwTextField;
         }
         else
         {
            this.m_title = addWidget(new ZwTextField(m_element.itemTitle_tf)) as ZwTextField;
         }
         if(Boolean(m_element.alive_tf_new) && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.alive_tf_new);
            this.m_alive = addWidget(new ZwTextField(m_element.alive_tf_new)) as ZwTextField;
         }
         else
         {
            this.m_alive = addWidget(new ZwTextField(m_element.alive_tf)) as ZwTextField;
         }
         if(Boolean(this.m_featureBuilding != null) && Boolean(m_element.sendMaterials_tf) && ZLocUtils.hasString("Dialogs",this.m_featureBuilding.bldgName + "_SendMaterials"))
         {
            addWidget(new ZwTextField(m_element.sendMaterials_tf,ZLocUtils.t("Dialogs",this.m_featureBuilding.bldgName + "_SendMaterials")));
         }
         else if(m_element.sendMaterials_tf)
         {
            addWidget(new ZwTextField(m_element.sendMaterials_tf,ZLocUtils.t("Dialogs","SendMaterials")));
         }
         if(m_element.available_tf)
         {
            addWidget(new ZwTextField(m_element.available_tf));
         }
         var hasEnoughCash:Boolean = true;
         if(this.m_expandComponent)
         {
            hasEnoughCash = this.m_expandComponent.getExpandCashNeeded() <= Global.player.cash || !this.m_expandComponent.inAppPurchase;
         }
         this.m_forceFrictionless = forceFrictionless;
         if(m_element.hasOwnProperty("completeNow_bt"))
         {
            if(hasEnoughCash)
            {
               if(!this.m_forceFrictionless)
               {
                  this.m_completeNowWidget = addWidget(new FarmAnimatedTextButton(m_element.completeNow_bt,ZLocUtils.t("Dialogs","CompleteNowCamel"),this.onCompleteNowCallback));
               }
               else
               {
                  this.m_completeNowWidget = addWidget(new FarmAnimatedTextButton(m_element.completeNow_bt,ZLocUtils.t("Dialogs","CompleteNowCamel"),this.onFrictionlessCompleteNowCallback));
               }
               this.setCompleteNowPrice();
            }
            else
            {
               this.m_completeNowWidget = addWidget(new FarmAnimatedTextButton(m_element.completeNow_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_get_farm_cash"),this.getMoreCashCallback));
            }
         }
         if(m_element.getThis_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_element.getThis_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_ask_for_more"),this.onAskMoreCallback));
         }
         if(m_element.use_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_element.use_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_remove"),null));
         }
         if(m_element.getFarmCash_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_element.getFarmCash_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_remove"),null));
         }
         if(m_element.present_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_element.present_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_send_gifts"),this.onSendPresentsCallback));
         }
         this.m_priceMultiplier = 1;
         if(this.m_expandComponent)
         {
            this.m_priceMultiplier = this.m_expandComponent.expandPriceMultiplier;
         }
         if(this.m_priceMultiplier > 0 && this.m_priceMultiplier < 1 && m_element.hasOwnProperty("fcPrice_Sale_mc"))
         {
            priceMovieClip = m_element.fcPrice_Sale_mc;
         }
         else if(m_element.hasOwnProperty("fcPrice_mc"))
         {
            priceMovieClip = m_element.fcPrice_mc;
         }
         if(this.m_forceFrictionless)
         {
            if(m_element.buy_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onFrictionlessBuyPartCallback));
            }
            if(m_element.buy2_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_element.buy2_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onFrictionlessBuyPartCallback));
            }
            if(m_element.use_mat_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_element.use_mat_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_use"),this.onUseCallback));
            }
            if(priceMovieClip)
            {
               this.m_frictionlessPrice = addWidget(new ZwBaseWidget(priceMovieClip));
            }
         }
         else if(m_element.hasOwnProperty("use_mat_bt") && m_element.hasOwnProperty("buy2_bt") && Boolean(priceMovieClip))
         {
            this.m_frictionlessBuy = true;
            addWidget(new FarmAnimatedTextButton(m_element.use_mat_bt,ZLocUtils.t("Dialogs","GenericExpansion_button_use"),this.addPart));
            addWidget(new FarmAnimatedTextButton(m_element.buy2_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onFrictionlessBuyPartCallback));
            this.m_frictionlessPrice = addWidget(new ZwBaseWidget(priceMovieClip));
         }
         else
         {
            this.m_frictionlessBuy = false;
            if(m_element.buy_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onBuyPartCallback));
            }
         }
         addWidget(new FarmIcon(m_element["icon"]));
         if(m_element.iconBox_mc != null)
         {
            addWidget(new ZwFrame(m_element.iconBox_mc));
         }
         if(m_element.hasOwnProperty(this.MC_SLOT))
         {
            slot80BGPath = Global.worldSettingsManager.getSlotBGImagePath("V80");
            if(slot80BGPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(slot80BGPath)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_element[this.MC_SLOT].addChild(this.m_slotBGIcon);
                  m_element[this.MC_SLOT].visible = true;
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      override public function release() : void
      {
         this.m_itemFrame = null;
         super.release();
      }
      
      protected function setPrice() : void
      {
         if(Boolean(this.m_frictionlessPrice) && Boolean(this.m_frictionlessPrice.element != null) && this.m_frictionlessPrice.element.hasOwnProperty("FCPrice_tf"))
         {
            this.m_frictionlessPrice.visible = true;
            this.m_frictionlessPrice.element.FCPrice_tf.text = this.m_expandComponent.getExpandCashNeeded();
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(this.m_frictionlessPrice.element.FCPrice_tf);
            }
            if(this.m_priceMultiplier > 0 && this.m_priceMultiplier < 1 && this.m_frictionlessPrice.element.hasOwnProperty("FCPrice_Old_tf"))
            {
               this.m_frictionlessPrice.element.FCPrice_Old_tf.text = this.m_featureBuilding.getRawExpansionPartsCost();
            }
         }
      }
      
      protected function setCompleteNowPrice() : void
      {
         if(Boolean(this.m_completeNowWidget) && this.m_completeNowWidget.element.hasOwnProperty("cost_tf"))
         {
            this.m_completeNowWidget.element.cost_tf.text = this.m_expandComponent.getExpandCashNeeded();
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemTitle:ZwTextField = null;
         var expandCount:Number = NaN;
         var expandLimit:Number = NaN;
         var buldingCode:String = null;
         var itemIcon:FarmIcon = null;
         var experiment:int = 0;
         var sendMats:ZwTextField = null;
         super.populate(data);
         this.m_data = data;
         this.m_dataItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         var iconBox:ZwFrame = null;
         if(m_element.iconBox_mc != null)
         {
            iconBox = getWidget(m_element.iconBox_mc) as ZwFrame;
         }
         var button:FarmAnimatedTextButton = null;
         if(this.m_dataItem != null)
         {
            itemTitle = null;
            if(m_element.itemTitle_tf_new)
            {
               itemTitle = getWidget(m_element.itemTitle_tf_new) as ZwTextField;
            }
            else
            {
               itemTitle = getWidget(m_element.itemTitle_tf) as ZwTextField;
            }
            itemTitle.text = ZLocUtils.tk_pk_asTitle(this.m_dataItem.friendlyName);
            itemTitle.visible = true;
            this.m_title = itemTitle;
            expandCount = this.m_expandComponent.getExpansionPartCount(this.m_dataItem.code);
            expandLimit = this.m_expandComponent.getExpansionPartLimit(this.m_dataItem.code);
            buldingCode = this.m_building.getInventoryCode().substr(0,3);
            if(buldingCode == "daN" || buldingCode == "da2" || buldingCode == "da1")
            {
               experiment = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HEAD_START);
               if(experiment == 2)
               {
                  expandCount += 3;
                  expandLimit += 3;
               }
               else if(experiment == 3)
               {
                  expandCount += 6;
                  expandLimit += 6;
               }
            }
            this.makeVisible(m_element.use_bt,false);
            if(this.m_forceFrictionless)
            {
               this.populateForcedFrictionlessButtons(expandCount,expandLimit);
            }
            else if(this.m_frictionlessBuy)
            {
               this.populateFrictionlessButtons(expandCount,expandLimit);
            }
            else
            {
               this.populateButtons(expandCount,expandLimit);
            }
            itemIcon = getWidget(m_element["icon"]) as FarmIcon;
            itemIcon.loadIcon(this.m_dataItem.icon);
            itemIcon.visible = true;
            itemIcon.setIconSize(50,50);
            itemIcon.setSmoothing(true);
            if(iconBox != null)
            {
               iconBox.visible = true;
            }
            if(this.m_itemFrame != null)
            {
               this.m_itemFrame.visible = true;
            }
         }
         else
         {
            if(m_element.sendMaterials_tf)
            {
               sendMats = getWidget(m_element.sendMaterials_tf) as ZwTextField;
               if(sendMats)
               {
                  sendMats.visible = true;
               }
            }
            if(m_element.completeNow_bt)
            {
               this.makeVisible(m_element.completeNow_bt);
            }
            if(m_element.present_bt)
            {
               this.makeVisible(m_element.present_bt);
            }
            this.makeVisible(m_element.getThis_bt,false);
            this.makeVisible(m_element.getFarmCash_bt,false);
            if(this.m_forceFrictionless)
            {
               if(this.m_frictionlessPrice)
               {
                  this.setPrice();
               }
               this.makeVisible(m_element.buy_bt,false);
               this.makeVisible(m_element.buy2_bt,false);
               this.makeVisible(m_element.use_mat_bt,false);
               if(Boolean(m_element.completeNow_bt) && Boolean(m_element.completeNow_bt.cost_tf))
               {
                  this.setCompleteNowPrice();
               }
            }
            else if(this.m_frictionlessBuy)
            {
               if(this.m_frictionlessPrice)
               {
                  this.setPrice();
               }
               button = getWidget(m_element.buy2_bt) as FarmAnimatedTextButton;
               button.visible = false;
               button = getWidget(m_element.use_mat_bt) as FarmAnimatedTextButton;
               button.visible = false;
            }
            else if(m_element.buy_bt)
            {
               button = getWidget(m_element.buy_bt) as FarmAnimatedTextButton;
               button.visible = false;
            }
            if(iconBox != null)
            {
               iconBox.visible = false;
            }
            if(this.m_itemFrame != null)
            {
               this.m_itemFrame.visible = false;
            }
         }
      }
      
      protected function populateButtons(expandCount:int, expandLimit:int) : void
      {
         var buyButton:FarmAnimatedTextButton = null;
         var askButton:FarmAnimatedTextButton = null;
         var completedFrame:ZwFrame = getWidget(m_element.completeIcon_mc) as ZwFrame;
         var completedText:ZwTextField = getWidget(m_element.completeIcon_mc.completed_tf) as ZwTextField;
         var liveMats:ZwTextField = this.m_alive;
         if(m_element.buy_bt)
         {
            buyButton = getWidget(m_element.buy_bt) as FarmAnimatedTextButton;
            buyButton.visible = true;
         }
         if(m_element.getThis_bt)
         {
            askButton = getWidget(m_element.getThis_bt) as FarmAnimatedTextButton;
            askButton.visible = true;
            this.updateAskFeedButton();
         }
         if(expandCount >= expandLimit)
         {
            completedFrame.visible = true;
            completedText.visible = true;
            if(buyButton)
            {
               buyButton.visible = false;
            }
            if(askButton)
            {
               askButton.visible = false;
            }
         }
         else
         {
            liveMats.text = ZLocUtils.t("Dialogs","GenericExpansion_part_level",{
               "quantity":expandCount,
               "maximum":expandLimit
            });
            liveMats.visible = true;
            completedFrame.visible = false;
            completedText.visible = false;
         }
      }
      
      private function makeVisible(element:Object, visible:Boolean = true) : Boolean
      {
         var elementButton:FarmAnimatedTextButton = null;
         var success:Boolean = false;
         if(element)
         {
            elementButton = getWidget(element) as FarmAnimatedTextButton;
            elementButton.visible = visible;
            success = true;
         }
         return success;
      }
      
      protected function populateFrictionlessButtons(expandCount:int, expandLimit:int) : void
      {
         var matsAvailable:int = 0;
         var useMatText:ZwTextField = null;
         var completedFrame:ZwFrame = getWidget(m_element.completeIcon_mc) as ZwFrame;
         var completedText:ZwTextField = getWidget(m_element.completeIcon_mc.completed_tf) as ZwTextField;
         var liveMats:ZwTextField = this.m_alive;
         var buyButton:FarmAnimatedTextButton = getWidget(m_element.buy2_bt) as FarmAnimatedTextButton;
         var askButton:FarmAnimatedTextButton = getWidget(m_element.getThis_bt) as FarmAnimatedTextButton;
         var useButton:FarmAnimatedTextButton = getWidget(m_element.use_mat_bt) as FarmAnimatedTextButton;
         buyButton.visible = true;
         askButton.visible = true;
         useButton.visible = true;
         this.updateAskFeedButton();
         if(expandCount >= expandLimit)
         {
            completedFrame.visible = true;
            completedText.visible = true;
            buyButton.visible = false;
            askButton.visible = false;
            useButton.visible = false;
            this.m_frictionlessPrice.visible = false;
         }
         else
         {
            matsAvailable = Global.player.getGiftCountForItem(this.m_dataItem.name);
            useMatText = getWidget(m_element.available_tf) as ZwTextField;
            if(useMatText)
            {
               useMatText.visible = false;
            }
            this.populatePartsButtons(liveMats,expandCount,expandLimit,completedFrame,completedText,matsAvailable,useMatText);
         }
      }
      
      protected function populateForcedFrictionlessButtons(expandCount:int, expandLimit:int) : void
      {
         var completedFrame:ZwFrame = getWidget(m_element.completeIcon_mc) as ZwFrame;
         var completedText:ZwTextField = getWidget(m_element.completeIcon_mc.completed_tf) as ZwTextField;
         var liveMats:ZwTextField = this.m_alive;
         var matsAvailable:int = Global.player.getGiftCountForItem(this.m_dataItem.name);
         var useMatText:ZwTextField = getWidget(m_element.available_tf) as ZwTextField;
         if(useMatText)
         {
            useMatText.visible = false;
         }
         if(expandCount >= expandLimit)
         {
            completedFrame.visible = true;
            completedText.visible = true;
            this.makeVisible(m_element.buy_bt,false);
            this.makeVisible(m_element.buy2_bt,false);
            this.makeVisible(m_element.getThis_bt,false);
            this.makeVisible(m_element.use_mat_bt,false);
         }
         else
         {
            this.populatePartsButtons(liveMats,expandCount,expandLimit,completedFrame,completedText,matsAvailable,useMatText);
         }
      }
      
      private function populatePartsButtons(liveMats:ZwTextField, expandCount:int, expandLimit:int, completedFrame:ZwFrame, completedText:ZwTextField, matsAvailable:int, useMatText:ZwTextField) : void
      {
         liveMats.text = ZLocUtils.t("Dialogs","GenericExpansion_part_level",{
            "quantity":expandCount,
            "maximum":expandLimit
         });
         liveMats.visible = true;
         completedFrame.visible = false;
         completedText.visible = false;
         if(matsAvailable > 0)
         {
            this.makeVisible(m_element.use_mat_bt);
            this.makeVisible(m_element.getThis_bt,false);
            this.makeVisible(m_element.buy2_bt,false);
            this.makeVisible(m_element.buy_bt,false);
            if(this.m_frictionlessPrice)
            {
               this.m_frictionlessPrice.visible = false;
            }
            if(useMatText)
            {
               useMatText.visible = true;
               useMatText.text = ZLocUtils.t("Dialogs","ConstructionBuildingMatAvailable",{"quantity":matsAvailable});
            }
         }
         else
         {
            if(this.makeVisible(m_element.buy_bt))
            {
               this.makeVisible(m_element.buy2_bt,false);
               if(m_element.buy_bt.cost_tf)
               {
                  m_element.buy_bt.cost_tf.text = this.m_dataItem.cash.toString();
               }
            }
            else if(this.makeVisible(m_element.buy2_bt))
            {
               this.makeVisible(m_element.buy_bt,false);
               if(m_element.buy2_bt.cost_tf)
               {
                  m_element.buy2_bt.cost_tf.text = this.m_dataItem.cash.toString();
               }
            }
            else
            {
               GlobalEngine.assert(false,"SWF missing a Buy button - buy_bt");
            }
            if(Boolean(this.m_frictionlessPrice) && Boolean(this.m_frictionlessPrice.element) && Boolean(this.m_frictionlessPrice.element.FCPrice_tf))
            {
               this.m_frictionlessPrice.visible = true;
               this.m_frictionlessPrice.element.FCPrice_tf.text = this.m_dataItem.cash.toString();
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(this.m_frictionlessPrice.element.FCPrice_tf);
               }
            }
            this.makeVisible(m_element.use_mat_bt,false);
            this.makeVisible(m_element.getThis_bt);
         }
         this.updateAskFeedButton();
      }
      
      protected function onBuyPartCallback(event:MouseEvent) : void
      {
         var messageText:String = null;
         var canBuy:Boolean = Global.player.canBuyCash(this.m_dataItem.cash,false);
         if(canBuy)
         {
            messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
               "item":ZLocUtils.tk_pk(this.m_dataItem.friendlyName),
               "cashQuantity":this.m_dataItem.cash
            });
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyPartAcceptCallback),false);
         }
         else
         {
            UI.displayPopup(new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH,this.m_dataItem.type),false,"buyMoreCashPopup",true);
         }
      }
      
      private function whichCashPackage() : Number
      {
         var pack:Object = null;
         var difference:int = 0;
         var cashPackages:Array = InGamePaymentsManager.packages;
         var smallestViable:Number = -1;
         var cashNeeded:Number = this.m_expandComponent.getExpandCashNeeded();
         var currentCash:Number = Global.player.cash;
         for each(pack in cashPackages)
         {
            difference = parseInt(pack["amount"]) + currentCash - cashNeeded;
            if(difference >= 0 && (difference < smallestViable || smallestViable == -1))
            {
               smallestViable = difference;
            }
         }
         if(smallestViable == -1)
         {
            FarmStatsManager.count("error","GenericExpandSlot","whichCashPackage","No package viable");
            smallestViable = currentCash - cashNeeded;
         }
         return smallestViable - currentCash + cashNeeded;
      }
      
      protected function getMoreCashCallback(event:MouseEvent) : void
      {
         PaymentUtil.instance.addCashToCart(this.whichCashPackage(),"CompleteNow:ThanksgivingBuildable2011",this.onSuccessGetMoreCash);
      }
      
      protected function onSuccessGetMoreCash(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(this.balanceRefreshed),true);
      }
      
      protected function balanceRefreshed(result:Object) : void
      {
         this.m_parentWindow.refreshWindow();
      }
      
      protected function onFrictionlessBuyPartCallback(event:MouseEvent) : void
      {
         FarmStatsManager.featureSample("Building","ui_button_click",this.m_building.getItem().name,"buy_part_frictionless",this.m_dataItem.name);
         var canBuy:Boolean = Global.player.canBuyCash(this.m_dataItem.cash,false);
         if(canBuy)
         {
            this.addPart(false);
         }
         else
         {
            UI.displayPopup(new ImpulseBuy(ImpulseBuy.TYPE_MARKET_CASH,this.m_dataItem.type),false,"buyMoreCashPopup",true);
         }
      }
      
      protected function onBuyPartAcceptCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_dataItem != null)
         {
            this.addPart(false);
         }
      }
      
      protected function onUseCallback(event:MouseEvent) : void
      {
         FarmStatsManager.featureSample("Building","ui_button_click",this.m_building.getItem().name,"use",this.m_dataItem.name);
         this.addPart(true);
      }
      
      protected function addPart(isGift:Boolean = false) : void
      {
         var oldStorageLevel:Number = NaN;
         var oldCashValue:int = 0;
         var newCashValue:int = 0;
         var newStorageLevel:Number = NaN;
         if(isGift || Global.player.canBuyCash(this.m_dataItem.cash,true))
         {
            if(!isGift && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDING_UI_CASH_BUY_COUNTER) > 0)
            {
               FarmStatsManager.sample(100,"fv_cash_buy","building",this.m_building.getItem().name + this.m_expandComponent.storageLevel.toString(),"buy_one",this.m_dataItem.cash.toString());
            }
            oldStorageLevel = this.m_expandComponent.storageLevel;
            oldCashValue = Global.player.cash;
            BuildingItemUseMediator.getInstance().mediate(this.m_dataItem.name,isGift,this.m_building,isGift);
            newCashValue = Global.player.cash;
            newStorageLevel = this.m_expandComponent.storageLevel;
            if(!isGift && oldCashValue == newCashValue)
            {
               Global.player.cash -= this.m_dataItem.cash;
            }
            if(oldStorageLevel == newStorageLevel)
            {
               this.populate(this.m_data);
               this.m_parentWindow.refreshWindow();
            }
            else
            {
               this.m_parentWindow.close();
            }
         }
      }
      
      protected function onSendPresentsCallback(event:MouseEvent) : void
      {
         this.m_parentWindow.close();
         UI.displayPopup(new CustomFreeGiftSelectionWindow(this.m_building.getPartsArray()));
      }
      
      protected function onCompleteNowCallback(event:MouseEvent) : void
      {
         this.m_expandComponent.beginCompleteExpansionFlow(FeatureBuilding.ACTION_SOURCE_LOOK_INSIDE_UI);
         this.m_parentWindow.close();
      }
      
      protected function onFrictionlessCompleteNowCallback(event:MouseEvent) : void
      {
         FarmStatsManager.featureSample("Building","ui_button_click",this.m_building.getItemName() + this.m_expandComponent.storageLevel.toString(),"frictionless_complete_now");
         this.m_expandComponent.frictionlessExpand();
         this.m_parentWindow.close();
      }
      
      protected function onAskMoreCallback(event:MouseEvent) : void
      {
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
         var expandAskType:String = this.m_featureBuilding != null && this.m_featureBuilding.expand != null ? this.m_featureBuilding.expand.getPartAskMethod(this.m_dataItem.code) : "";
         if(expandAskType == FeatureBuilding.PART_ASK_METHOD_FEED && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDABLE_PART_FEED) > 0)
         {
            this.m_waitingFeedCallback = true;
            (getWidget(m_element.getThis_bt) as FarmAnimatedTextButton).enabled = false;
            this.m_featureBuilding.requestExpansionPart(this.m_dataItem,this.updateAskFeedButton);
         }
         else if(expandAskType == FeatureBuilding.PART_ASK_METHOD_CRAFT)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINIRECIPE_WINDOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && this.m_dataItem != null)
            {
               WishingFountainWindow.openMakeRecipeWindow(this.m_building.getItemName(),this.m_dataItem.code);
               this.m_parentWindow.close();
            }
            else
            {
               WishingFountainWindow.openMakeRecipeWindow(this.m_building.getItemName());
            }
         }
         else
         {
            MFSRequestManager.getInstance().makeAskMatsRequest(this.m_building.getItem().name,this.m_dataItem.name,"","1",MFSConstants.SOURCE_DIALOG_CLICKED);
         }
      }
      
      protected function updateAskFeedButton(result:Object = null) : void
      {
         var expandAskType:String = null;
         if(result != null)
         {
            this.m_waitingFeedCallback = false;
         }
         var askButton:FarmAnimatedTextButton = getWidget(m_element.getThis_bt) as FarmAnimatedTextButton;
         if(Boolean(askButton) && Boolean(this.m_featureBuilding) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUILDABLE_PART_FEED) > 0)
         {
            expandAskType = this.m_featureBuilding.expand.getPartAskMethod(this.m_dataItem.code);
            if(expandAskType == FeatureBuilding.PART_ASK_METHOD_FEED)
            {
               askButton.enabled = !this.m_waitingFeedCallback && this.m_featureBuilding.canRequestPartFeed(this.m_dataItem.code);
               if(askButton.enabled)
               {
                  askButton.text = ZLocUtils.t("Dialogs","GenericAsk");
               }
               else
               {
                  askButton.text = ZLocUtils.t("Dialogs","Posted");
               }
            }
            else if(expandAskType == FeatureBuilding.PART_ASK_METHOD_CRAFT)
            {
               askButton.text = "Craft";
            }
            else
            {
               askButton.enabled = true;
            }
         }
      }
   }
}

