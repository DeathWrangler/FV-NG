package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.MapResource;
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemDefinition;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.UGC.UGCItemLayerState;
   import Classes.UGC.UGCItemState;
   import Classes.UGCAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.IUGCItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.DynamicObjectEvent;
   import Events.GenericPopupEvent;
   import Managers.DreamFishPremarketingManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.FeatureOptionsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TCreateUGCItem;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.UGC.UGCFishItemEditorFrame;
   import Widgets.Frames.UGC.UGCItemPaintingFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.events.Event;
   
   public class UGCFishItemEditorWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const PM_FEATURE_CURRENCY_NAME:String = "fishfood";
      
      private static const PM_FO_KEY_FISH_GRANT:String = "grantFreeFish";
      
      private static const CONSUMABLE_REQUIRED:int = 50;
      
      public static const STATS_CREATE_PM:String = "_create_pm";
      
      public static const STATS_CREATE_GIFT:String = "_create_gift";
      
      public static const STATS_CREATE_REGULAR:String = "_create_regular";
      
      private const PREVIEW_INFO_FRAME_SEEN:String = "dream_fish_previewInfo_frame_seen";
      
      private var m_ugcItem:IUGCItem;
      
      private var m_customizeItem:IUGCMapResource = null;
      
      protected var m_whatIsThis_mc:FarmAnimatedTextButton;
      
      private var m_previewInfo_mc:ZwFrame;
      
      private var m_confirm_mc:ZwFrame;
      
      private var m_preview_mc:ZwFrame;
      
      private var m_asserPreview:UGCItemPaintingFrame;
      
      private var m_closeWarningFrame:ZwFrame;
      
      private var m_freeFishFrame:ZwFrame;
      
      private var m_freeGiftFrame:ZwFrame;
      
      private var m_iconMc:ZwFrame;
      
      private var m_editor:UGCFishItemEditorFrame;
      
      private var m_assetPreviewFrame:UGCItemPaintingFrame;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const PREVIEWINFO_MC:String = "previewInfo_mc";
      
      private const CONFIRM_MC:String = "confirm_mc";
      
      private const PREVIEW_MC:String = "preview_mc";
      
      private const CONTAINER_MC:String = "container_mc";
      
      private const ASSET_MC:String = "asset_mc";
      
      private const CLOSEWARNING_MC:String = "closeWarning_mc";
      
      private const RESET_BT:String = "reset_bt";
      
      private const SEND_BT:String = "send_bt";
      
      private const ICON_MC:String = "icon_mc";
      
      private const RANDOM_BT:String = "random_bt";
      
      private const OKAY_BT:String = "okay_bt";
      
      private const BUY_BT:String = "buy_bt";
      
      private const CREATING_MC:String = "creating_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SUBTITLE_TF:String = "subtitle_tf";
      
      private const HEADER_TF:String = "header_tf";
      
      private const GENERIC_TF:String = "generic_tf";
      
      private const SLOT_MC:String = "slot_mc";
      
      private const CLOSE_BT:String = "close_bt";
      
      private const GOBACK_BT:String = "goBack_bt";
      
      private const CONTINUE_BT:String = "continue_bt";
      
      private const FREEFISH_MC:String = "freeFish_mc";
      
      private const FREEGift_MC:String = "freeGift_mc";
      
      private const TEXT_TITLE:String = "ugc_fish_title";
      
      private const TEXT_HEADER:String = "ugc_fish_header";
      
      private const TEXT_SEND_BUTTON_FRAME:String = "ugc_fish_send_button_frame_text";
      
      private const TEXT_CLOSE_WARNING:String = "ugc_fish_closeWarning";
      
      private const CONFIRM_TITLE_TEXT:String = "ugc_fish_confirm_title_text";
      
      private const CONFIRM_SUBTITLE_TEXT:String = "ugc_fish_confirm_subtitle_text";
      
      private const PREVIEW_TITLE_TEXT:String = "ugc_fish_preview_title_text";
      
      private const PREVIEW_SUBTITLE_TEXT:String = "ugc_fish_preview_text";
      
      private const TEXT_FISH_BOWL_TOOLTIP:String = "ugc_fish_giftMessage";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_RESET_BTN:String = "Reset";
      
      private const TEXT_RANDOM_BTN:String = "Random";
      
      private var m_totalCash:int;
      
      private var m_createType:String = "_create_regular";
      
      public function UGCFishItemEditorWindow(ugcItem:IUGCItem = null, customizeItem:IUGCMapResource = null, gameSettingsFeatureName:String = null)
      {
         ugcItem = Global.farmGameSettingsManager.getFarmItemByName("ugc_fish1") as IUGCItem;
         this.m_ugcItem = ugcItem;
         this.m_customizeItem = customizeItem;
         var ugcItemDefinition:UGCItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition(this.m_ugcItem.ugcItemName);
         var tutorialPageCount:int = NUM_TUTORIAL_SCENES;
         var isEAUser:Boolean = WorldSeasonsManager.getInstance().isEAUser(Global.worldManager.currentWorldType);
         if(isEAUser)
         {
            tutorialPageCount++;
         }
         var actionStatsText:String = "create_new";
         if(this.m_customizeItem)
         {
            actionStatsText = "customize";
         }
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_context",actionStatsText);
         super(this.m_ugcItem.ugcItemName,ugcItemDefinition.editorConfig.dialogPath,tutorialPageCount,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         var fishFoodCount:int = 0;
         var FOValue:int = 0;
         var buyButtonText:String = null;
         var isEAUser:Boolean = false;
         var showfreeFishFrame:Boolean = false;
         var FOValue1:Boolean = false;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(this.HEADER_TF))
         {
            addWidget(new ZwTextField(m_window[this.HEADER_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_HEADER)));
         }
         if(m_window.hasOwnProperty(this.RANDOM_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.RANDOM_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_RANDOM_BTN),this.onRandomClick));
         }
         if(m_window.hasOwnProperty(this.RESET_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.RESET_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_RESET_BTN),this.onResetClick));
         }
         this.configureWidgets();
         if(m_window.hasOwnProperty(this.CONTAINER_MC))
         {
            this.m_editor = new UGCFishItemEditorFrame(m_window[this.CONTAINER_MC],this.m_assetPreviewFrame,this.m_ugcItem,this.m_customizeItem);
            this.m_editor.addEventListener(UGCConstants.EVENT_REFRESH,this.handleRefresh);
            if(m_window.hasOwnProperty(this.PREVIEW_MC))
            {
               this.m_editor.addEventListener(UGCConstants.EVENT_PREVIEW_ITEM,this.onPreviewItem);
            }
            addWidget(this.m_editor,true);
         }
         if(m_window.hasOwnProperty(this.BUY_BT))
         {
            this.m_totalCash = this.m_editor.totalCash;
            fishFoodCount = FeatureOptionsInventoryManager.getInstance().getCountByName(PM_FEATURE_CURRENCY_NAME);
            FOValue = int(FeatureOptionsManager.getInstance().getFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_FISH_GRANT));
            if(fishFoodCount >= CONSUMABLE_REQUIRED && FOValue == 0)
            {
               this.m_totalCash = 0;
               this.m_createType = STATS_CREATE_PM;
            }
            buyButtonText = "Buy and Place";
            if(this.m_totalCash == 0)
            {
               buyButtonText = "Place for Free";
               if(this.m_createType == STATS_CREATE_REGULAR)
               {
                  this.m_createType = STATS_CREATE_GIFT;
               }
            }
            addWidget(new FarmAnimatedCashButton(m_window[this.BUY_BT],buyButtonText,this.m_totalCash.toString(),this.onBuyClick));
         }
         if(m_window.hasOwnProperty(this.CREATING_MC))
         {
            addWidget(new ZwFrame(m_window[this.CREATING_MC]),false);
         }
         if(m_window.hasOwnProperty(this.PREVIEWINFO_MC))
         {
            this.m_previewInfo_mc = addWidget(new ZwFrame(m_window[this.PREVIEWINFO_MC]),false) as ZwFrame;
            this.m_previewInfo_mc.addWidget(new FarmAnimatedTextButton(m_window[this.PREVIEWINFO_MC][this.OKAY_BT],ZLocUtils.t("Dialogs","Okay"),this.onClickPreviewInfo));
            isEAUser = WorldSeasonsManager.getInstance().isEAUser(Global.worldManager.currentWorldType);
            if(!isEAUser && FarmGameUtil.checkStartDateGate(UGCConstants.UNDERWATER_GA_CONTENT_DROP_DATE))
            {
               if(!Global.player.getSeenFlag(this.PREVIEW_INFO_FRAME_SEEN))
               {
                  Global.player.setSeenFlag(this.PREVIEW_INFO_FRAME_SEEN);
                  this.m_previewInfo_mc.visible = true;
               }
            }
         }
         if(m_window.hasOwnProperty(this.FREEFISH_MC))
         {
            showfreeFishFrame = false;
            if(!this.m_customizeItem)
            {
               if(fishFoodCount >= CONSUMABLE_REQUIRED)
               {
                  FOValue1 = Boolean(FeatureOptionsManager.getInstance().getFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_FISH_GRANT));
                  showfreeFishFrame = !FOValue1;
               }
            }
            this.m_freeFishFrame = addWidget(new ZwFrame(m_window[this.FREEFISH_MC]),showfreeFishFrame) as ZwFrame;
         }
         if(m_window.hasOwnProperty(this.FREEGift_MC))
         {
            this.m_freeGiftFrame = addWidget(new ZwFrame(m_window[this.FREEGift_MC]),!showfreeFishFrame) as ZwFrame;
            if(m_window[this.FREEGift_MC].hasOwnProperty([this.GENERIC_TF]))
            {
               this.m_freeGiftFrame.addWidget(new ZwTextField(m_window[this.FREEGift_MC][this.GENERIC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_SEND_BUTTON_FRAME)));
            }
            if(m_window[this.FREEGift_MC].hasOwnProperty([this.SEND_BT]))
            {
               this.m_freeGiftFrame.addWidget(new FarmAnimatedTextButton(m_window[this.FREEGift_MC][this.SEND_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Send"),this.onSendButtonClick));
            }
            if(m_window[this.FREEGift_MC].hasOwnProperty([this.ICON_MC]))
            {
               this.m_freeGiftFrame.addWidget(this.m_iconMc = new ZwFrame(m_window[this.FREEGift_MC][this.ICON_MC]));
               this.m_iconMc.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_FISH_BOWL_TOOLTIP)));
            }
         }
         if(m_window.hasOwnProperty(this.CLOSEWARNING_MC))
         {
            addWidget(this.m_closeWarningFrame = new ZwFrame(m_window[this.CLOSEWARNING_MC]),false);
            if(m_window[this.CLOSEWARNING_MC].hasOwnProperty([this.CLOSE_BT]))
            {
               this.m_closeWarningFrame.addWidget(new FarmAnimatedTextButton(m_window[this.CLOSEWARNING_MC][this.CLOSE_BT],"Leave the Studio",this.onCloseWarningClose));
            }
            if(m_window[this.CLOSEWARNING_MC].hasOwnProperty([this.CONTINUE_BT]))
            {
               this.m_closeWarningFrame.addWidget(new FarmAnimatedTextButton(m_window[this.CLOSEWARNING_MC][this.CONTINUE_BT],"Continue Designing",this.onCloseWarningContinue));
            }
            if(m_window[this.CLOSEWARNING_MC].hasOwnProperty([this.GENERIC_TF]))
            {
               this.m_closeWarningFrame.addWidget(new ZwTextField(m_window[this.CLOSEWARNING_MC][this.GENERIC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_CLOSE_WARNING)));
            }
         }
         if(m_window.hasOwnProperty(this.CONFIRM_MC))
         {
            this.m_confirm_mc = addWidget(new ZwFrame(m_window[this.CONFIRM_MC]),false) as ZwFrame;
            if(m_window[this.CONFIRM_MC].hasOwnProperty([this.GOBACK_BT]))
            {
               this.m_confirm_mc.addWidget(new FarmAnimatedTextButton(m_window[this.CONFIRM_MC][this.GOBACK_BT],"Go Back!",this.onGoBackConfirmBtnClick));
            }
            if(m_window[this.CONFIRM_MC].hasOwnProperty([this.CONTINUE_BT]))
            {
               this.m_confirm_mc.addWidget(new FarmAnimatedTextButton(m_window[this.CONFIRM_MC][this.CONTINUE_BT],"Place",this.onContinueConfirmBtnClick));
            }
            if(m_window[this.CONFIRM_MC].hasOwnProperty([this.TITLE_TF]))
            {
               this.m_confirm_mc.addWidget(new ZwTextField(m_window[this.CONFIRM_MC][this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.CONFIRM_TITLE_TEXT)));
            }
            if(m_window[this.CONFIRM_MC].hasOwnProperty([this.SUBTITLE_TF]))
            {
               this.m_confirm_mc.addWidget(new ZwTextField(m_window[this.CONFIRM_MC][this.SUBTITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.CONFIRM_SUBTITLE_TEXT)));
            }
         }
         if(m_window.hasOwnProperty(this.PREVIEW_MC))
         {
            this.m_preview_mc = addWidget(new ZwFrame(m_window[this.PREVIEW_MC]),false) as ZwFrame;
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.SLOT_MC]))
            {
               this.m_preview_mc.addWidget(new ZwFrame(m_window[this.PREVIEW_MC][this.SLOT_MC]));
               this.m_preview_mc.addWidget(new FarmIcon(m_window[this.PREVIEW_MC][this.SLOT_MC].icon));
               this.m_preview_mc.addWidget(new ZwFrame(m_window[this.PREVIEW_MC][this.SLOT_MC].iconBox_mc));
            }
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.ASSET_MC]))
            {
               this.m_preview_mc.addWidget(this.m_asserPreview = new UGCItemPaintingFrame(m_window[this.PREVIEW_MC][this.ASSET_MC],this.m_ugcItem.farmItem,[3]));
            }
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.GOBACK_BT]))
            {
               this.m_preview_mc.addWidget(new FarmAnimatedTextButton(m_window[this.PREVIEW_MC][this.GOBACK_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Close"),this.onGoBackPreviewBtnClick));
            }
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.BUY_BT]))
            {
               this.m_preview_mc.addWidget(new FarmAnimatedCashButton(m_window[this.PREVIEW_MC][this.BUY_BT],"Unlock",UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE.toString()));
            }
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.TITLE_TF]))
            {
               this.m_preview_mc.addWidget(new ZwTextField(m_window[this.PREVIEW_MC][this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.PREVIEW_TITLE_TEXT)));
            }
            if(m_window[this.PREVIEW_MC].hasOwnProperty([this.SUBTITLE_TF]))
            {
               this.m_preview_mc.addWidget(new ZwTextField(m_window[this.PREVIEW_MC][this.SUBTITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.PREVIEW_SUBTITLE_TEXT)));
            }
         }
         super.postLoadComplete();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_editor.disablePaintMode();
         showTutorial();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.m_editor.disablePaintMode();
         this.setCloseWarningVisibility(true);
      }
      
      override protected function release() : void
      {
         this.m_editor.removeEventListener(UGCConstants.EVENT_REFRESH,this.handleRefresh);
         this.m_editor.removeEventListener(UGCConstants.EVENT_PREVIEW_ITEM,this.onPreviewItem);
         this.m_editor = null;
         this.m_ugcItem = null;
         this.m_whatIsThis_mc = null;
         this.m_customizeItem = null;
         this.m_previewInfo_mc = null;
         this.m_confirm_mc = null;
         this.m_preview_mc = null;
         this.m_asserPreview = null;
         this.m_closeWarningFrame = null;
         this.m_freeFishFrame = null;
         this.m_freeGiftFrame = null;
         this.m_iconMc = null;
         this.m_assetPreviewFrame = null;
         super.release();
      }
      
      private function onRandomClick(event:Event) : void
      {
         this.m_editor.randomize();
      }
      
      private function onResetClick(event:Event) : void
      {
         this.m_editor.reset();
      }
      
      private function onClickPreviewInfo(event:Event) : void
      {
         this.m_previewInfo_mc.visible = false;
      }
      
      private function onSendButtonClick(event:Event) : void
      {
         var fishBowlGiftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("ugc_fish_gift");
         UI.displayPopup(new MFSSendPaidGift(fishBowlGiftItem,UGCConstants.DREAM_FISH_KEYWORD,this.toggleInput),false);
         this.toggleInput(false);
      }
      
      private function toggleInput(enabled:Boolean = true) : void
      {
         if(enabled)
         {
            this.untintWindow();
         }
         else
         {
            this.tintWindow();
         }
         this.enableInput = enabled;
      }
      
      private function onCloseWarningClose(event:Event) : void
      {
         close();
      }
      
      private function onGoBackConfirmBtnClick(event:Event) : void
      {
         this.m_confirm_mc.visible = false;
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_popup","go_back");
      }
      
      private function onContinueConfirmBtnClick(event:Event) : void
      {
         this.performBuyAction();
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_popup","accept");
      }
      
      private function onGoBackPreviewBtnClick(event:Event) : void
      {
         this.m_preview_mc.visible = false;
      }
      
      private function onCloseWarningContinue(event:Event) : void
      {
         this.setCloseWarningVisibility(false);
      }
      
      private function setCloseWarningVisibility(visible:Boolean) : void
      {
         if(this.m_closeWarningFrame != null)
         {
            if(this.m_closeWarningFrame.visible != visible)
            {
               this.m_closeWarningFrame.visible = visible;
            }
         }
      }
      
      private function onBuyClick(event:Event) : void
      {
         this.m_editor.disablePaintMode();
         if(this.m_editor.isDefaultFish())
         {
            this.m_confirm_mc.visible = true;
         }
         else
         {
            this.performBuyAction();
         }
      }
      
      private function performBuyAction() : void
      {
         this.m_confirm_mc.visible = false;
         if(this.m_totalCash > 10)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":this.m_totalCash}),GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"farmAnimatedCashConfirmation",true,true);
         }
         else
         {
            this.buyAction();
         }
      }
      
      private function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.buyAction();
         }
      }
      
      private function buyAction() : void
      {
         var fishFoodCount:int = 0;
         var FOValue:int = 0;
         var state:UGCItemState = this.m_editor.ugcItemState;
         if(state.isValid())
         {
            fishFoodCount = FeatureOptionsInventoryManager.getInstance().getCountByName(PM_FEATURE_CURRENCY_NAME);
            FOValue = int(FeatureOptionsManager.getInstance().getFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_FISH_GRANT));
            if(fishFoodCount >= CONSUMABLE_REQUIRED && FOValue == 0)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,PM_FO_KEY_FISH_GRANT,1);
            }
            if(Global.player.canBuyCash(this.m_totalCash))
            {
               Utilities.toggleInputAndChildren(m_window,false);
               getWidget(this.BUY_BT).visible = false;
               getWidget(this.CREATING_MC).visible = true;
               StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + this.m_createType,this.m_ugcItem.farmItem.name,this.m_editor.getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_PATTERN),this.m_editor.getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_TAILS),this.m_editor.getSelectedItemNameForLayer(UGCConstants.LAYER_KEY_FINS),this.m_totalCash.toString());
               TransactionManager.addTransaction(new TCreateUGCItem(state,this.m_totalCash,this.m_editor.getCustomizeItem(),this.onCreateTxComplete),true);
            }
         }
      }
      
      private function onCreateTxComplete(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var extraData:Object = null;
         if(ugcItemState != null)
         {
            if(!existingItem)
            {
               extraData = {
                  "ugcUuid":ugcItemState.uuid,
                  "repopGift":false
               };
               Global.world.enterForcePlaceMode(this.m_ugcItem.farmItem.name,false,0,false,true,extraData);
            }
            else
            {
               this.transformItem(ugcItemState,existingItem);
            }
         }
         close();
      }
      
      private function transformItem(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var currentPosition:Vector3 = (existingItem as MapResource).getPosition();
         var id:Number = (existingItem as MapResource).getId();
         (existingItem as MapResource).detach();
         var ugcItem:UGCAnimal = new UGCAnimal(this.m_ugcItem.farmItem.name,ugcItemState.uuid);
         ugcItem.setOuter(Global.world);
         ugcItem.setPosition(currentPosition.x,currentPosition.y,currentPosition.z);
         ugcItem.conditionallyReattach();
         ugcItem.setId(id);
         ugcItem.ugcDelegate.refresh();
      }
      
      private function handleRefresh(event:DynamicObjectEvent) : void
      {
         var widget:ZwWidget = null;
         var newItem:IUGCItem = event.data as IUGCItem;
         if(this.m_ugcItem != newItem)
         {
            for each(widget in [this.m_assetPreviewFrame])
            {
               if(widget != null)
               {
                  removeWidget(widget);
               }
            }
            this.m_ugcItem = newItem;
            this.configureWidgets();
            this.m_editor.assetFrame = this.m_assetPreviewFrame;
            this.m_editor.ugcItem = newItem;
            this.m_editor.reset();
         }
      }
      
      public function configureWidgets() : void
      {
         if(m_window.hasOwnProperty(this.ASSET_MC))
         {
            this.m_assetPreviewFrame = new UGCItemPaintingFrame(m_window[this.ASSET_MC],this.m_ugcItem.farmItem,[4]);
            addWidget(this.m_assetPreviewFrame,true);
         }
      }
      
      private function onPreviewItem(event:DynamicObjectEvent) : void
      {
         var slotFrame:ZwFrame;
         var buyButton:FarmAnimatedCashButton;
         var item:FarmItem = null;
         var icon:FarmIcon = null;
         var iconBox:ZwFrame = null;
         var ugcResource:IUGCMapResource = null;
         var layerState:UGCItemLayerState = null;
         item = event.data.item as FarmItem;
         var layerDef:UGCItemLayerDefinition = event.data.layer as UGCItemLayerDefinition;
         this.m_preview_mc.visible = true;
         slotFrame = this.m_preview_mc.getWidget(this.SLOT_MC) as ZwFrame;
         if(slotFrame != null)
         {
            slotFrame.visible = true;
            icon = this.m_preview_mc.getWidget("icon") as FarmIcon;
            if(icon != null)
            {
               icon.loadIcon(item.iconUrl);
               icon.setIconScale(0.6,0.6);
               icon.setSmoothing(true);
               icon.visible = true;
               iconBox = this.m_preview_mc.getWidget("iconBox_mc") as ZwFrame;
               if(iconBox != null)
               {
                  iconBox.visible = true;
               }
            }
         }
         if(this.m_asserPreview != null)
         {
            ugcResource = this.m_asserPreview.mapResource as IUGCMapResource;
            ugcResource.ugcDelegate.ugcItemState = this.m_editor.ugcItemState;
            if(layerDef.isItemValid(item.name))
            {
               layerState = ugcResource.ugcDelegate.ugcItemState.getLayerStateByDefinition(layerDef,false);
               if(layerState != null)
               {
                  layerState.itemCode = item.code;
               }
               ugcResource.ugcDelegate.refresh();
            }
         }
         buyButton = this.m_preview_mc.getWidget(this.BUY_BT) as FarmAnimatedCashButton;
         if(buyButton != null)
         {
            buyButton.callback = function():void
            {
               onPreviewBuyBtnClick(item);
            };
         }
      }
      
      private function onPreviewBuyBtnClick(item:FarmItem) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(UGCConstants.SERVICE_CLASS,UGCConstants.SERVICE_METHOD_UNLOCK_PART,null,[item.name]),true);
         FeatureOptionsManager.getInstance().setFeatureOption(UGCConstants.FO_AOE_LICENSE,item.aoeLicenseKey,true) as Boolean;
         Global.player.cash -= UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE;
         this.m_preview_mc.visible = false;
         this.m_editor.refreshItemSelector();
         StatsManager.count(UGCConstants.DREAM_FISH_KEYWORD + "_unlock","",item.name,"unlock","",UGCConstants.DREAM_FISH_PART_UNLOCK_PRICE.toString());
      }
   }
}

