package Widgets.Windows.GiftBox
{
   import Classes.FarmSocialNetwork;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GiftBox.GiftBoxSlotFrame;
   import Widgets.ProgressBars.GiftBoxProgressBar;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Timer;
   
   public class GiftBoxWindow extends FarmWindow
   {
      
      public static const TOO_MANY_GIFTS_SEEN:String = "tooManyGifts";
      
      private static const REGIFT_FRIEND_REWARD_AC_KEY:String = "actionCount_regiftFriendReward";
      
      public static var dailyRegiftCount:int = Global.player.getIntervalActionCount(REGIFT_FRIEND_REWARD_AC_KEY);
      
      public static var isReGiftOptionAvailable:Boolean = true;
      
      public static var PER_ITEM_QUANTITY_LIMIT:int = 10000;
      
      public static const GIFT_BOX_DELETION_EXPT:String = "fv_giftBoxDeletion";
      
      public static const GIFT_BOX_LIMIT_CHECK_EXPT:String = "fv_giftBoxLimitCheckChanged";
      
      public static const PRELIM_WARNING_VALUE:int = 100;
      
      public static const FULL_WARNING_VALUE:int = 100;
      
      public const MAX_NUMBER_OF_RE_GIFTS:int = 3;
      
      private var m_shareWishlistButton:FarmAnimatedTextButton;
      
      private var m_searchBar_mc:ZwWidget;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton;
      
      private var m_clearedSearch:Boolean = false;
      
      private var m_search_mc:ZwWidget;
      
      private var m_searchField_tf:ZwTextField;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private var m_slotFrame:GiftBoxSlotFrame;
      
      private var m_totalGiftPrices:Number;
      
      private var m_titleText:ZwTextField;
      
      private var m_grayoutMovieClip:ZwWidget;
      
      private var m_fillBarText:FarmTextField;
      
      private var m_completionMeter:GiftBoxProgressBar;
      
      private var m_glowTimer:Timer;
      
      public function GiftBoxWindow()
      {
         var asset:String = "";
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            asset = "assets/dialogs/FV_GiftBox_v3.swf";
         }
         else
         {
            asset = "assets/dialogs/FV_GiftBox.swf";
         }
         super(asset);
      }
      
      override protected function postLoadComplete() : void
      {
         var giftboxMessage:String = null;
         addWidget(new ZwTextField(m_window.giftbox_tf,ZLocUtils.t("Dialogs","GiftBox_Title")));
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_fillBarText = addWidget(new FarmTextField(m_window["giftBoxLimit_txt"],Global.player.getGifts().length + " out of " + Global.farmGameSettingsManager.getInt("maxGiftLimit"))) as FarmTextField;
            this.m_completionMeter = addWidget(new GiftBoxProgressBar(m_window.loader_mc,0,Global.farmGameSettingsManager.getInt("maxGiftLimit"))) as GiftBoxProgressBar;
            this.m_grayoutMovieClip = addWidget(new ZwWidget(m_window.lightBox_mc)) as ZwWidget;
            this.m_grayoutMovieClip.visible = false;
         }
         else if(m_window.body_tf)
         {
            giftboxMessage = Global.flashHotParams["GIFTBOX_MESSAGE"];
            if(Boolean(giftboxMessage) && giftboxMessage.length > 1)
            {
               addWidget(new ZwTextField(m_window.body_tf,giftboxMessage));
            }
         }
         this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
         var searchString:String = UI.windowState != null && UI.windowState.giftbox != null && UI.windowState.giftbox["searchString"] != "" ? UI.windowState.giftbox["searchString"] : this.m_defaultString;
         this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,searchString)) as ZwTextField;
         this.m_clearedSearch = this.m_searchField_tf.text != this.m_defaultString;
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
         m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
         this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
         this.m_search_mc = addWidget(new ZwWidget(m_window.searchBar_mc.search_mc)) as ZwWidget;
         if(Global.farmSocialNetwork.getSocialNetworkId() == FarmSocialNetwork.SNID_FACEBOOK)
         {
            this.m_shareWishlistButton = addWidget(new FarmAnimatedTextButton(m_window.share_bt,ZLocUtils.t("Dialogs","GiftBox_ShareWishlist"),this.onShareWishlistClick)) as FarmAnimatedTextButton;
         }
         var gifts:Array = this.getGifts(Global.player.getGifts());
         this.m_slotFrame = addWidget(new GiftBoxSlotFrame(m_window.slotFrame_mc,gifts,this)) as GiftBoxSlotFrame;
         this.reload();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_shareWishlistButton = null;
         this.m_searchBar_mc = null;
         this.m_searchField_tf = null;
         this.m_clearSearchButton_mc = null;
         this.m_slotFrame = null;
         this.m_glowTimer = null;
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         MarketWindow.onGiftboxClosePopupCheck();
      }
      
      public function reload() : void
      {
         FarmGame.cbTrace("Giftbox reloaded. Current giftbox version: " + Global.player.giftsVersion);
         var searchString:String = this.m_clearedSearch ? this.m_searchField_tf.text.toLocaleLowerCase() : "";
         var gifts:Array = this.getGifts(Global.player.getGifts());
         this.m_slotFrame.reload(gifts,searchString);
         if(this.m_searchField_tf.text == "")
         {
            this.m_clearSearchButton_mc.visible = false;
            this.m_search_mc.visible = true;
         }
         else
         {
            this.m_clearSearchButton_mc.visible = true;
            this.m_search_mc.visible = false;
         }
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_completionMeter.progress = Global.player.getGifts().length;
            if(this.m_completionMeter.progress >= this.m_completionMeter.maximum)
            {
               this.glow(this.m_completionMeter.element);
            }
            else if(this.m_glowTimer != null)
            {
               this.m_glowTimer.stop();
            }
            this.updateTitleText();
            this.m_fillBarText.text = Global.player.getGifts().length + " out of " + Global.farmGameSettingsManager.getInt("maxGiftLimit");
         }
      }
      
      private function timerListener(mv:Object) : Function
      {
         var f:Function = function(ev:TimerEvent):void
         {
            addOrRemoveGlow(mv);
         };
         return f;
      }
      
      private function addOrRemoveGlow(mv:Object) : void
      {
         var glowObj:GlowFilter = new GlowFilter();
         glowObj.color = 13369344;
         glowObj.blurX = 25;
         glowObj.blurY = 25;
         if(Boolean(mv.filters.hasOwnProperty("0")) && mv.filters["0"].alpha == 1)
         {
            glowObj.alpha = 0;
         }
         else
         {
            glowObj.alpha = 1;
         }
         mv.filters = [glowObj];
      }
      
      private function glow(mv:Object) : void
      {
         this.m_glowTimer = new Timer(1000);
         this.m_glowTimer.addEventListener(TimerEvent.TIMER,this.timerListener(mv));
         this.m_glowTimer.start();
      }
      
      private function updateTitleText() : void
      {
         if(this.m_titleText == null)
         {
            this.m_titleText = addWidget(new ZwTextField(m_window.body_tf,"")) as ZwTextField;
         }
         if(this.percentCompletion() < PRELIM_WARNING_VALUE)
         {
            this.m_titleText.text = ZLocUtils.t("Dialogs","GiftBoxWarningText1");
         }
         else if(this.percentCompletion() < FULL_WARNING_VALUE)
         {
            this.m_titleText.text = ZLocUtils.t("Dialogs","GiftBoxWarningText2");
         }
         else if(this.percentCompletion() == FULL_WARNING_VALUE)
         {
            this.m_titleText.text = ZLocUtils.t("Dialogs","GiftBoxWarningText3");
         }
         else if(this.percentCompletion() > FULL_WARNING_VALUE)
         {
            this.m_titleText.text = ZLocUtils.t("Dialogs","GiftBoxWarningText4");
         }
      }
      
      private function percentCompletion() : int
      {
         return int(Global.player.getGifts().length / Global.farmGameSettingsManager.getInt("maxGiftLimit") * 100);
      }
      
      override public function show() : void
      {
         FarmGame.cbTrace("Giftbox shown. Current giftbox version: " + Global.player.giftsVersion);
         super.show();
      }
      
      private function onSearchTextButtonClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchField_tf.text == this.m_defaultString)
         {
            this.m_searchField_tf.text = "";
            this.m_clearedSearch = true;
         }
      }
      
      public function clearSearch() : void
      {
         this.m_searchField_tf.text = "";
         this.m_clearedSearch = true;
         this.m_slotFrame.restoreAllDeselected();
         this.reload();
      }
      
      public function isDefaultSearchTextString() : Boolean
      {
         return this.m_searchField_tf.text == this.m_defaultString;
      }
      
      private function onClearSearchButtonClick(event:MouseEvent) : void
      {
         this.clearSearch();
      }
      
      public function grayOutorUngrayOutBG(value:Boolean) : void
      {
         this.m_grayoutMovieClip.visible = value;
      }
      
      private function onConfirmationDialogClosed(ev:MouseEvent) : void
      {
         this.m_grayoutMovieClip.visible = false;
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_slotFrame.restoreAllDeselected();
            this.m_slotFrame.resetPage();
         }
         else
         {
            this.m_slotFrame.deselectAll();
            this.m_slotFrame.setPage(0,this.m_searchField_tf.text.length,event.charCode);
         }
         this.reload();
      }
      
      private function getGifts(objects:Array) : Array
      {
         var objectIdx:int = 0;
         var object:Object = null;
         var giftObj:StorageItem = null;
         var item:FarmItem = null;
         var className:String = null;
         var consumableClass:Boolean = false;
         var giftXML:XML = null;
         var data:Array = [];
         var usedTypes:Object = new Object();
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = new Object();
               giftObj = objects[objectIdx] as StorageItem;
               if(Boolean(giftObj) && Boolean(giftObj.item))
               {
                  item = giftObj.item;
                  if(usedTypes[giftObj.itemKey] == null)
                  {
                     usedTypes[giftObj.itemKey] = giftObj.quantity;
                     object.itemKey = giftObj.itemKey;
                     object.name = Global.farmGameSettingsManager.getFarmItemNameByCode(giftObj.itemKey);
                     object.farmItem = item;
                     object.itemName = object.name;
                     object.friendlyName = item.friendlyName;
                     object.className = item.className;
                     object.rank = item.sortPriority;
                     object.type = item.category != "" ? item.category : item.type;
                     className = item.className;
                     consumableClass = className == "LootableDecoration" || className == "BuildingPart" || className == "WateringCan" || className == "SocialPlumbingMysteryGift" || className == "FeatureCreditItem" || className == "MysterySeedling" || className == "Collection";
                     if(item.type == "fuel" || item.subType == "consumable" || consumableClass)
                     {
                        object.type = "consumable";
                     }
                     if(item.type == "change_farm")
                     {
                        object.type = item.subType;
                     }
                     object.subType = item.subType;
                     object.localizedName = item.friendlyTitle.toLocaleLowerCase();
                     object.cost = item.cost;
                     object.level = giftObj.level;
                     object.subText1 = giftObj.getDisplaySubtext1();
                     object.subText2 = giftObj.getDisplaySubtext2();
                     object.compId = objectIdx;
                     object.sellPrice = item.sellPrice;
                     if(FarmGameSettingsManager.isInDataSourceExperiment())
                     {
                        if(item.hasPropertyInDataSource("coinYield"))
                        {
                           object.coinYield = item.getNumberFromDataSource("coinYield");
                        }
                        if(item.hasPropertyInDataSource("growTime"))
                        {
                           object.harvestTime = item.getNumberFromDataSource("growTime");
                        }
                     }
                     else
                     {
                        giftXML = item.xml;
                        if(giftXML.coinYield)
                        {
                           object.coinYield = giftXML.coinYield;
                        }
                        if(giftXML.growTime)
                        {
                           object.harvestTime = giftXML.growTime;
                        }
                     }
                     if(item.sizeX)
                     {
                        object.sizeX = item.sizeX;
                     }
                     if(item.sizeY)
                     {
                        object.sizeX = item.sizeY;
                     }
                     object.quantity = giftObj.quantity;
                     object.senderIds = giftObj.senderIds;
                     data.push(object);
                  }
               }
            }
         }
         return data;
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         this.m_shareWishlistButton.enabled = enable;
         this.m_slotFrame.setButtonEnable(enable);
         this.m_searchBar_mc.enabled = enable;
         m_window.close_bt.enabled = enable;
      }
      
      override public function close() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt.enabled))
         {
            if(UI.windowState == null)
            {
               UI.windowState = {"giftbox":{}};
            }
            if(UI.windowState.giftbox == null)
            {
               UI.windowState.giftbox = {};
            }
            if(!this.m_clearedSearch)
            {
               this.m_searchField_tf.text = "";
            }
            UI.windowState.giftbox["searchString"] = this.m_searchField_tf.text;
            super.close();
         }
      }
      
      private function noMoreGiftsHandler(event:GenericPopupEvent) : void
      {
         var result:Boolean = event.button == GenericPopup.YES;
         if(result == true)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_accept");
            this.close();
            FreeGiftSelectionWindow.popWindow();
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_cancel");
            this.setButtonEnable(true);
         }
      }
      
      private function onShareWishlistClick(event:MouseEvent) : void
      {
         this.close();
         if(Global.farmSocialNetwork.getSocialNetworkId() == FarmSocialNetwork.SNID_FACEBOOK)
         {
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","giftbox_share_wishlist");
            Global.farmSocialNetwork.farmRedirect("gifts.php?template=wishlist&ref=gift_box");
         }
         else
         {
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","giftbox_share_wishlist_zlive");
            GlobalEngine.socialNetwork.redirect("gifts.php?ref=zlive");
         }
      }
   }
}

