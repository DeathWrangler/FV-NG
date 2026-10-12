package Widgets.Windows
{
   import Classes.FixedTreasureConstructionBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Engine.Helpers.Vector3;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Managers.JMInnovationManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class TreasureHoverOverWindow extends HoverOverWindow
   {
      
      private static const OFFSET_X:int = -22;
      
      private static const OFFSET_Y:int = 100;
      
      private static const ICON_SCALE:Number = 1;
      
      private static const ICON_OFFSET_X:int = 0;
      
      private static const ICON_OFFSET_Y:int = 0;
      
      protected static const WINDOW_ASSET:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf";
      
      private var m_requestTypeToUse:String;
      
      private var m_feedPostingState:String = "";
      
      private var m_hasPartsNow:Boolean = false;
      
      private var m_part:PartItem = null;
      
      private var m_treasureBuilding:FixedTreasureConstructionBuilding = null;
      
      private var m_treasureItem:FarmItem = null;
      
      private var m_completeNowButton:FarmAnimatedCashButton = null;
      
      private var m_addPartButton:FarmAnimatedTextButton = null;
      
      private var m_whatsThis:FarmAnimatedButton = null;
      
      private var m_partsAddedSoFar:ZwTextField = null;
      
      private var m_headerTextfield:ZwTextField = null;
      
      private var m_partIcon:FarmIcon = null;
      
      private var m_noPartsCallback:Function = null;
      
      private var m_whatIsThisCallback:Function = null;
      
      private var m_completeNowCallback:Function = null;
      
      private var m_getCashNeededCallback:Function = null;
      
      private var m_getInventoryPartsUseableCountCallback:Function = null;
      
      private var m_getTotalPartsCountCallback:Function = null;
      
      private var m_getCurrentPartsCountCallback:Function = null;
      
      private var m_usePartsCallback:Function = null;
      
      private var m_getNoPartsLabelCallback:Function = null;
      
      private var m_getTrackingIDCallback:Function = null;
      
      private var m_JMInnovationManager:JMInnovationManager = null;
      
      private var m_innovationMC:MovieClip = null;
      
      public function TreasureHoverOverWindow(treasure:FixedTreasureConstructionBuilding, feedPostingState:String, callBackObject:Object, requestTypeToUse:String, timerTime:int = -1, windowAsset:String = "assets/dialogs/Asia/FV_xas_treasureTip.swf")
      {
         var part:PartItem = null;
         this.m_treasureBuilding = treasure;
         var originPoint:Vector3 = this.m_treasureBuilding.getPosition();
         var treasureItem:FarmItem = this.m_treasureBuilding.getItem();
         part = this.m_treasureBuilding.getMostNeededItem();
         super(originPoint,windowAsset,timerTime);
         m_offsetY = OFFSET_Y;
         m_offsetX = OFFSET_X;
         this.m_treasureItem = treasureItem;
         this.m_feedPostingState = feedPostingState;
         this.m_requestTypeToUse = requestTypeToUse;
         this.m_part = part;
         this.m_JMInnovationManager = JMInnovationManager.getInstance();
         this.refreshCallbacks(callBackObject);
      }
      
      private function refreshCallbacks(callBackObject:Object) : void
      {
         this.m_noPartsCallback = callBackObject["noPartsCallback"];
         this.m_whatIsThisCallback = callBackObject["whatIsThisCallback"];
         this.m_completeNowCallback = callBackObject["completeNowCallback"];
         this.m_getCashNeededCallback = callBackObject["getCashNeededCallback"];
         this.m_getInventoryPartsUseableCountCallback = callBackObject["inventoryPartCountUseableCallback"];
         this.m_getTotalPartsCountCallback = callBackObject["getTotalPartsCallback"];
         this.m_getCurrentPartsCountCallback = callBackObject["getCurrentPartsCallback"];
         this.m_usePartsCallback = callBackObject["usePartsCallback"];
         this.m_getNoPartsLabelCallback = callBackObject["getNoPartsLabel"];
         this.m_getTrackingIDCallback = callBackObject["getTrackingID"];
      }
      
      private function getProgressText(partItem:PartItem) : String
      {
         var item:FarmItem = partItem.item;
         return ZLocUtils.t("Dialogs","hoverOverWindow_progress",{
            "current":this.m_getCurrentPartsCountCallback(item.code),
            "total":this.m_getTotalPartsCountCallback(item),
            "part":ZLocUtils.tk_pk_asTitlePlural(partItem.friendlyName)
         });
      }
      
      private function conditionallyDisplayJungleInnovationCard() : void
      {
         if(this.m_innovationMC)
         {
            this.m_innovationMC.visible = false;
            if(this.m_JMInnovationManager.isActive())
            {
               this.m_innovationMC.visible = true;
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var lockedText:String = null;
         var treasureDialogPath:String = null;
         var loaderDialog:Loader = null;
         super.postLoadComplete();
         this.m_innovationMC = m_window.innovation_mc;
         this.conditionallyDisplayJungleInnovationCard();
         var lockedTextVisible:Boolean = false;
         if(m_window.hasOwnProperty("locked_tf"))
         {
            lockedText = PrerequisiteUtility.getPrerequisiteFailureDescription(this.m_treasureBuilding.getFailedContextPrereq());
            if(lockedText == null)
            {
               lockedText = "";
            }
            else
            {
               lockedTextVisible = true;
            }
            addWidget(new ZwTextField(m_window.locked_tf,lockedText),lockedTextVisible);
         }
         this.m_headerTextfield = new ZwTextField(m_window.header_tf,ZLocUtils.tk_pk_asTitle(this.m_treasureItem.friendlyName));
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.header_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.header_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.header_tf);
         }
         this.m_partsAddedSoFar = new ZwTextField(m_window.subheader_tf,this.getProgressText(this.m_part));
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.subheader_tf);
         }
         this.m_completeNowButton = new FarmAnimatedCashButton(m_window.complete_bt,ZLocUtils.t("Dialogs","storage_complete_now"),"0",this.onClickCompleteNow);
         this.m_addPartButton = new FarmAnimatedTextButton(m_window.use_bt,this.m_getNoPartsLabelCallback(),this.onClickAddPart);
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            this.m_whatsThis = new FarmAnimatedButton(m_window.whatisthis_mc,this.onClickWhatsThis);
         }
         addWidget(this.m_headerTextfield,!lockedTextVisible);
         addWidget(this.m_partsAddedSoFar,!lockedTextVisible);
         addWidget(this.m_completeNowButton,!lockedTextVisible);
         addWidget(this.m_addPartButton,!lockedTextVisible);
         if(this.m_whatsThis)
         {
            addWidget(this.m_whatsThis,!lockedTextVisible);
         }
         if(m_window.hasOwnProperty("mc_TreasureDialog"))
         {
            treasureDialogPath = Global.worldSettingsManager.getSlotBGImagePath("treasureDialog");
            if(treasureDialogPath)
            {
               loaderDialog = LoadingManager.load(Global.getAssetURL(treasureDialogPath));
               m_window["mc_TreasureDialog"].addChild(loaderDialog);
               m_window["mc_TreasureDialog"].visible = true;
            }
         }
         this.refreshIcon(lockedTextVisible);
         this.updateUI();
         show();
      }
      
      public function beginCloseTimer() : void
      {
         if(m_timerTime > -1)
         {
            m_fadeOutTimer.start();
         }
      }
      
      private function refreshIcon(hide:Boolean = false) : void
      {
         var iconPath:String = this.m_part.item.icon;
         var currency:String = this.m_part.getCurrency();
         if(currency != null)
         {
            iconPath = Global.getAssetURL(Currency.getIcon(currency));
         }
         this.m_partIcon = new FarmIcon(m_window.icon_mc,iconPath);
         this.m_partIcon.setIconScale(ICON_SCALE,ICON_SCALE);
         this.m_partIcon.x += ICON_OFFSET_X;
         this.m_partIcon.y += ICON_OFFSET_Y;
         addWidget(this.m_partIcon,!hide);
      }
      
      public function updateAndShow(treasure:FixedTreasureConstructionBuilding, feedPostingState:String, callBackObject:Object, requestTypeToUse:String, timerTime:int = -1) : void
      {
         var lockedTextWidget:ZwTextField = null;
         var lockedText:String = null;
         this.m_treasureBuilding = treasure;
         var originPoint:Vector3 = this.m_treasureBuilding.getPosition();
         var treasureItem:FarmItem = this.m_treasureBuilding.getItem();
         var part:PartItem = this.m_treasureBuilding.getMostNeededItem();
         updateOrigin(originPoint);
         this.refreshCallbacks(callBackObject);
         this.m_treasureItem = treasureItem;
         this.m_feedPostingState = feedPostingState;
         this.m_requestTypeToUse = requestTypeToUse;
         updateTimerUse(timerTime);
         var lockedTextVisible:Boolean = false;
         if(m_window.hasOwnProperty("locked_tf"))
         {
            lockedTextWidget = getWidget(m_window.locked_tf) as ZwTextField;
            if(lockedTextWidget)
            {
               lockedText = PrerequisiteUtility.getPrerequisiteFailureDescription(this.m_treasureBuilding.getFailedContextPrereq());
               if(lockedText == null)
               {
                  lockedText = "";
               }
               else
               {
                  lockedTextVisible = true;
               }
               lockedTextWidget.visible = lockedTextVisible;
               lockedTextWidget.text = lockedText;
            }
         }
         this.m_headerTextfield.visible = !lockedTextVisible;
         this.m_partsAddedSoFar.visible = !lockedTextVisible;
         this.m_completeNowButton.visible = !lockedTextVisible;
         this.m_addPartButton.visible = !lockedTextVisible;
         if(this.m_whatsThis)
         {
            this.m_whatsThis.visible = !lockedTextVisible;
         }
         if(part.item.code != this.m_part.item.code)
         {
            this.m_part = part;
            removeWidget(this.m_partIcon);
            this.refreshIcon(lockedTextVisible);
         }
         else
         {
            this.m_partIcon.visible = !lockedTextVisible;
         }
         alignWindowOrigin();
         this.updateUI();
         show();
         if(m_timerTime < 0)
         {
            recentlyOpened = true;
         }
      }
      
      public function updateButtonStatesFromFeed(feedPostingState:String) : void
      {
         this.m_feedPostingState = feedPostingState;
         this.updateUI();
      }
      
      private function updateJungleInnovationText() : void
      {
         if(this.m_JMInnovationManager.isActive())
         {
            if(this.m_innovationMC)
            {
               this.m_innovationMC.count_tf.text = "x" + this.m_JMInnovationManager.getConjuringGems(this.m_treasureBuilding.getItemName());
            }
         }
      }
      
      private function updateUI() : void
      {
         var useablePartCount:int = this.m_getInventoryPartsUseableCountCallback(this.m_part);
         if(useablePartCount > 0)
         {
            this.m_addPartButton.text = ZLocUtils.t("Dialogs","FixedTreasure_Menu_UseParts_count",{"count":useablePartCount});
            this.m_addPartButton.enabled = true;
            this.m_hasPartsNow = true;
         }
         else
         {
            if(this.m_feedPostingState == FixedTreasureConstructionBuilding.FEED_STATUS_READY || this.m_requestTypeToUse != FixedTreasureConstructionBuilding.ASK_PARTS_FEED)
            {
               this.m_addPartButton.enabled = true;
            }
            else if(this.m_feedPostingState == FixedTreasureConstructionBuilding.FEED_STATUS_POSTED)
            {
               this.m_addPartButton.enabled = false;
               if(this.m_addPartButton.element.hasOwnProperty("spinning_mc"))
               {
                  this.m_addPartButton.element.spinning_mc.visible = false;
               }
            }
            else
            {
               this.m_addPartButton.enabled = false;
               if(this.m_addPartButton.element.hasOwnProperty("spinning_mc"))
               {
                  this.m_addPartButton.element.spinning_mc.visible = true;
               }
            }
            this.m_addPartButton.text = this.m_getNoPartsLabelCallback();
            this.m_hasPartsNow = false;
         }
         this.m_completeNowButton.setAmountText(this.m_getCashNeededCallback().toString());
         this.m_headerTextfield.text = ZLocUtils.tk_pk_asTitle(this.m_treasureItem.friendlyName);
         this.m_partsAddedSoFar.text = this.getProgressText(this.m_part);
         this.updateJungleInnovationText();
      }
      
      private function onClickAddPart(e:MouseEvent) : void
      {
         if(this.m_hasPartsNow)
         {
            this.m_usePartsCallback();
            FarmStatsManager.count("fixed_treasure",this.m_treasureItem.name,"hover_menu_clicked","usePart",this.m_getTrackingIDCallback());
         }
         else
         {
            this.m_noPartsCallback();
            FarmStatsManager.count("fixed_treasure",this.m_treasureItem.name,"hover_menu_clicked","ask_friends",this.m_getTrackingIDCallback());
         }
         hide();
      }
      
      private function onClickCompleteNow(e:MouseEvent) : void
      {
         this.m_completeNowCallback();
         hide();
         FarmStatsManager.count("fixed_treasure",this.m_treasureItem.name,"hover_menu_clicked","complete_now",this.m_getTrackingIDCallback());
      }
      
      private function onClickWhatsThis(e:MouseEvent) : void
      {
         this.m_whatIsThisCallback();
         hide();
         FarmStatsManager.count("fixed_treasure",this.m_treasureItem.name,"hover_menu_clicked","whatIsThis",this.m_getTrackingIDCallback());
      }
   }
}

