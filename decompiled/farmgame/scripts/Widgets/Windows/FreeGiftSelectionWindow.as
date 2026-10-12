package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.LESurfacingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FreeGiftsSlotContainerFrame;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class FreeGiftSelectionWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_flashFreeGifts.swf";
      
      private static const ASSET_URL_V1:String = "assets/dialogs/FV_flashFreeGifts_v1.swf";
      
      public static const NO_TO_UID:String = "-1";
      
      private static var m_freeGiftsList:Array = null;
      
      private static var m_freeFilteredGiftsList:Array = null;
      
      private static var m_giftsLoading:Boolean = false;
      
      private static var m_dialogInstance:FreeGiftSelectionWindow = null;
      
      private var m_slotContainerFrame:FreeGiftsSlotContainerFrame = null;
      
      private var m_loadingSpinner:ZwWidget = null;
      
      private var m_toUid:String = "-1";
      
      protected var m_searchBar_mc:ZwWidget = null;
      
      private var m_searchField_tf:ZwTextField = null;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton = null;
      
      private var m_search_mc:ZwWidget = null;
      
      private var m_searchHighlite_mc:ZwWidget = null;
      
      private var m_clearedSearch:Boolean = false;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private const FREE_GIFTING_CLEANUP_V1_SEEN_FLAG:String = "FreeGiftingCleanup_v1";
      
      public function FreeGiftSelectionWindow(toUid:String = "-1")
      {
         var asset_path:String = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FREE_GIFT_SELECTION_V1) >= 1)
         {
            asset_path = ASSET_URL_V1;
         }
         else
         {
            asset_path = ASSET_URL;
         }
         super(asset_path);
         this.m_toUid = toUid;
      }
      
      public static function giftsLoaded() : Boolean
      {
         return m_freeGiftsList != null;
      }
      
      public static function giftsLoading() : Boolean
      {
         return m_giftsLoading;
      }
      
      public static function loadFreeGifts() : void
      {
         if(!(giftsLoading() || giftsLoaded()))
         {
            m_giftsLoading = true;
            TransactionManager.addTransaction(new TGenericTransaction("GiftingService","getGiftNameList",onGiftsLoaded));
         }
      }
      
      public static function onGiftsLoaded(result:Object) : void
      {
         var itemName:String = null;
         var giftItem:FarmItem = null;
         if((result as Array).length > 0)
         {
            m_freeGiftsList = new Array();
            m_freeFilteredGiftsList = new Array();
            for each(itemName in result)
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               if(giftItem != null)
               {
                  m_freeGiftsList.push(giftItem);
               }
            }
            m_freeFilteredGiftsList = m_freeGiftsList;
            if(m_dialogInstance != null)
            {
               m_dialogInstance.m_slotContainerFrame.update();
               m_dialogInstance.m_loadingSpinner.visible = false;
            }
         }
      }
      
      public static function get freeGifts() : Array
      {
         return m_freeFilteredGiftsList;
      }
      
      public static function popWindow(toUid:String = "-1") : void
      {
         if(m_dialogInstance == null)
         {
            loadFreeGifts();
            m_dialogInstance = new FreeGiftSelectionWindow(toUid);
            UI.displayPopup(m_dialogInstance);
         }
      }
      
      public static function closeWindow() : void
      {
         if(m_dialogInstance != null)
         {
            m_dialogInstance.close();
            m_dialogInstance = null;
         }
      }
      
      public static function getToUid() : String
      {
         var result:String = NO_TO_UID;
         if(m_dialogInstance != null)
         {
            result = m_dialogInstance.m_toUid;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var searchString:String = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.txt_header,ZLocUtils.t("Dialogs","FreeGiftsSelection_Title")));
         addWidget(new ZwTextField(m_window.txt_body,ZLocUtils.t("Dialogs","FreeGiftsSelection_Subtitle")));
         addWidget(new ZwWidget(m_window.mc_background));
         addWidget(new ZwWidget(m_window.mc_scene));
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FREE_GIFT_SELECTION_V1) >= 1)
         {
            this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
            searchString = UI.windowState != null && UI.windowState.market != null && UI.windowState.market["searchString"] != "" ? UI.windowState.market["searchString"] : this.m_defaultString;
            this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,searchString)) as ZwTextField;
            m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
            m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
            m_window.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
            m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
            this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
            if(m_window.searchBar_mc.clearsearch_bt == null)
            {
               if(m_window.searchBar_mc.search_bt != null)
               {
                  this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.search_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
               }
            }
            else
            {
               this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
            }
            if(m_window.searchBar_mc.search_mc != null)
            {
               this.m_search_mc = addWidget(new ZwWidget(m_window.searchBar_mc.search_mc)) as ZwWidget;
            }
            if(m_window.searchBar_mc.highlight_mc != null)
            {
               this.m_searchHighlite_mc = addWidget(new ZwWidget(m_window.searchBar_mc.highlight_mc)) as ZwWidget;
               if(Global.player.getSeenFlag(this.FREE_GIFTING_CLEANUP_V1_SEEN_FLAG))
               {
                  removeWidget(this.m_searchHighlite_mc);
               }
               else
               {
                  Global.player.setSeenFlag(this.FREE_GIFTING_CLEANUP_V1_SEEN_FLAG,true);
               }
            }
         }
         this.m_slotContainerFrame = addWidget(new FreeGiftsSlotContainerFrame(m_window.slotContainer_mc),true) as FreeGiftsSlotContainerFrame;
         this.m_loadingSpinner = addWidget(new ZwWidget(m_window.mc_loader)) as ZwWidget;
         this.m_loadingSpinner.visible = !giftsLoaded();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_slotContainerFrame = null;
         this.m_loadingSpinner = null;
      }
      
      override public function close() : void
      {
         m_freeFilteredGiftsList = m_freeGiftsList;
         this.m_slotContainerFrame = null;
         this.m_loadingSpinner = null;
         m_dialogInstance = null;
         super.close();
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
      
      private function onClearSearchButtonClick(event:MouseEvent) : void
      {
         this.clearSearch();
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         LESurfacingManager.instance.onCloseMarketDialog();
         Global.overrideDebugKeys = true;
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         this.reload();
      }
      
      public function reload() : void
      {
         this.filterItems();
         var searchString:String = this.m_clearedSearch ? this.m_searchField_tf.text.toLocaleLowerCase() : "";
         this.m_slotContainerFrame.update();
         this.m_slotContainerFrame.pageNumber = 0;
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
      }
      
      public function isDefaultSearchTextString() : Boolean
      {
         return this.m_searchField_tf.text == this.m_defaultString;
      }
      
      public function clearSearch() : void
      {
         this.m_searchField_tf.text = "";
         this.m_clearedSearch = true;
         this.reload();
      }
      
      public function filterItems() : void
      {
         var giftItem:FarmItem = null;
         m_freeFilteredGiftsList = new Array();
         var searchString:String = this.m_clearedSearch ? this.m_searchField_tf.text.toLocaleLowerCase() : "";
         if(searchString != "" && searchString != this.m_defaultString)
         {
            for each(giftItem in m_freeGiftsList)
            {
               if(giftItem != null)
               {
                  if(giftItem.friendlyTitle.toLocaleLowerCase().search(searchString.toLocaleLowerCase()) != -1)
                  {
                     m_freeFilteredGiftsList.push(giftItem);
                  }
               }
            }
         }
         else
         {
            m_freeFilteredGiftsList = m_freeGiftsList;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FreeGiftsSlotContainerFrame.firstPage = 1;
         super.onClose(event);
      }
   }
}

