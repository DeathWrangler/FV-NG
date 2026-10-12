package Widgets.Windows.Collections
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.Constants.CollectionsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.CollectionsManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TGiftGive;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AutoCloseToasterWindow;
   import com.greensock.TimelineLite;
   import com.greensock.TweenAlign;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   
   public class CollectionsToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "collectionsToaster";
      
      protected static const DEFAULT_SHOW_TWEEN_TIME:Number = 0.75;
      
      protected static const DEFAULT_HIDE_TWEEN_TIME:Number = 0.75;
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 5000;
      
      protected static const FIRST_TIME_FOUND_KEY:String = "FirstTimeFoundCollectable";
      
      protected static const POPUP_ICON_WIDTH:Number = 50;
      
      protected static const POPUP_ICON_HEIGHT:Number = 50;
      
      protected static const TOASTER_Y_OFFSET:Number = 120;
      
      protected var DIALOG_ASSET:String = "assets/dialogs/FV_BannerAd_Collections.swf";
      
      protected var m_item:FarmItem;
      
      protected var m_collectibleCode:String;
      
      protected var m_collection:Collection = CollectionsManager.getInstance().getCollectionByCollectibleCode(this.m_collectibleCode);
      
      protected var m_shareLink:String;
      
      protected var m_rarity:String;
      
      private var m_shouldClose:Boolean = !this.m_collection.isCollectionComplete();
      
      private var m_iconToTween:FarmIcon;
      
      public function CollectionsToasterWindow(collectibleCode:String, shareLink:String = "")
      {
         this.m_collectibleCode = collectibleCode;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_collectibleCode);
         this.m_shareLink = shareLink;
         super(this.DIALOG_ASSET);
         this.name = POPUP_NAME;
      }
      
      override protected function postLoadComplete() : void
      {
         var tradeIn:FarmAnimatedTextButton = null;
         var viewBtn:FarmAnimatedTextButton = null;
         var collectible:Collectible = null;
         var slotWidget:ZwBaseWidget = null;
         var popupIcon:FarmIcon = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.tk_pk_asTitle("Collections:" + this.m_collection.name + CollectionsConstants.FRIENDLY_NAME)));
         if(this.m_collection.isCollectionComplete())
         {
            tradeIn = addWidget(new FarmAnimatedTextButton(m_window.trade_bt,ZLocUtils.t("Collections","TradeIn"),this.viewCollectionsClick)) as FarmAnimatedTextButton;
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Collections","Complete")));
            addWidget(new ZwButton(m_window.closeCompleted_bt,this.onClose));
            addWidget(new ZwBaseWidget(m_window.completedBackground_mc));
            SoundManager.addOrPlaySound("sfx_collectible",Global.getAssetURL(CollectionsConstants.SFX_COLLECTION_COMPLETE));
         }
         else
         {
            viewBtn = addWidget(new FarmAnimatedTextButton(m_window.view_bt,ZLocUtils.t("Collections","View"),this.viewCollectionsClick)) as FarmAnimatedTextButton;
            addWidget(new ZwBaseWidget(m_window.collectBackground_mc));
         }
         for(var i:int = 0; i < this.m_collection.getTotalCollectablesCount(); i++)
         {
            collectible = this.m_collection.getCollectableByIndex(i);
            if(Global.player.collectionCounters[collectible.code] > 0)
            {
               slotWidget = new ZwBaseWidget(m_window["slotOn_" + i + "_mc"]);
               if(Global.player.collectionCounters[collectible.code] >= collectible.numNeeded)
               {
                  addWidget(new ZwBaseWidget(m_window["checkmark_" + i + "_mc"]),true);
               }
            }
            else
            {
               slotWidget = new ZwBaseWidget(m_window["slotNull_" + i + "_mc"]);
            }
            addWidget(slotWidget,true);
            popupIcon = new FarmIcon(m_window["icon_" + i + "_mc"]);
            popupIcon.loadIcon(collectible.item.icon);
            popupIcon.setIconSize(POPUP_ICON_WIDTH,POPUP_ICON_HEIGHT);
            if(collectible.code == this.m_collectibleCode)
            {
               this.m_iconToTween = popupIcon;
            }
            if(Global.player.collectionCounters[collectible.code] <= 0)
            {
               slotWidget.element.alpha = 0.5;
               slotWidget.element.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
            addWidget(popupIcon);
         }
         if(!Collection.isSlotMachineCollection(this.m_collection))
         {
            this.displayOtherPopups();
         }
      }
      
      override protected function showTweenComplete() : void
      {
         var startX:Number = NaN;
         var startY:Number = NaN;
         var timeline:TimelineLite = null;
         if(this.m_iconToTween != null)
         {
            startX = this.m_iconToTween.x;
            startY = this.m_iconToTween.y;
            timeline = new TimelineLite();
            timeline.appendMultiple([new TweenLite(this.m_iconToTween.element,0.4,{
               "scaleX":1.5,
               "scaleY":1.5,
               "x":startX - POPUP_ICON_WIDTH * 0.25,
               "y":startY - POPUP_ICON_WIDTH * 0.25,
               "delay":0.35,
               "ease":Sine.easeOut
            }),new TweenLite(this.m_iconToTween.element,0.3,{
               "scaleX":1,
               "scaleY":1,
               "x":startX,
               "y":startY,
               "alpha":1,
               "ease":Sine.easeOut
            })],0,TweenAlign.SEQUENCE);
         }
         super.showTweenComplete();
      }
      
      override protected function onTimer(event:TimerEvent) : void
      {
         if(this.m_shouldClose)
         {
            close();
         }
      }
      
      private function viewCollectionsClick(event:Event) : void
      {
         this.close();
         if(this.m_shouldClose)
         {
            FarmStatsManager.count("collections","progress_toaster_clickview",this.m_collection.name,"","",Global.worldManager.currentWorldType);
         }
         else
         {
            FarmStatsManager.count("collections","complete_toaster_tradein",this.m_collection.name,"","",Global.worldManager.currentWorldType);
         }
         UI.displayPopup(new CollectionsWindow(this.m_collection));
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("collections","complete_toaster_close",this.m_collection.name,"","",Global.worldManager.currentWorldType);
         close();
      }
      
      protected function renderCollections() : void
      {
         addWidget(new ZwFrame(m_window.foundPopUp_mc));
         var current:int = this.m_collection.getCurrentUniqueCollectablesCount();
         var total:int = this.m_collection.getTotalCollectablesCount();
         addWidget(new ZwTextField(m_window.foundPopUp_mc.popUpTitle_tf,ZLocUtils.t("Dialogs","CollectionsStatusTitle",{"item":ZLocUtils.tk_pk(this.m_item.friendlyName)})));
         addWidget(new ZwTextField(m_window.foundPopUp_mc.popUpBody_tf,ZLocUtils.t("Dialogs","CollectionsStatusBody",{
            "quantity":current,
            "quantityTotal":total,
            "set":ZLocUtils.tk_pk(this.m_collection.friendlyName)
         })));
         addWidget(new ZwButton(m_window.foundPopUp_mc.hitbox_mc,this.onHitBoxClick));
         if(this.m_collection.isCollectionComplete())
         {
            hideTween(null);
            addWidget(new ZwButton(m_window.foundPopUp_mc.close_bt,this.onClose));
            addWidget(new ZwBaseWidget(m_window.completedBackground_mc));
         }
         var popupIcon:FarmIcon = new FarmIcon(m_window.foundPopUp_mc.popUpIcon);
         popupIcon.loadIcon(this.m_item.icon);
         popupIcon.setIconSize(POPUP_ICON_WIDTH,POPUP_ICON_HEIGHT);
         addWidget(popupIcon);
      }
      
      protected function displayOtherPopups() : void
      {
         var newCollectible:Collectible = null;
         var message:String = null;
         var iconPopup:GenericIconPopup = null;
         if("" != this.m_shareLink)
         {
            newCollectible = this.m_collection.getCollectable(this.m_collectibleCode);
            if(Boolean(newCollectible) && Boolean(newCollectible.item) && (newCollectible.rarityString == CollectionsConstants.RARITY_UNCOMMON || newCollectible.rarityString == CollectionsConstants.RARITY_RARE))
            {
               message = ZLocUtils.t("Dialogs","ShareFoundCollectable",{"item":ZLocUtils.tk_pk(newCollectible.item.friendlyName)});
               iconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,newCollectible.item.icon);
               Global.popupManager.addInactiveUserPopup(iconPopup);
            }
         }
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_shouldClose)
         {
            FarmStatsManager.count("collections","progress_toaster_clickbody",this.m_collection.name,"","",Global.worldManager.currentWorldType);
         }
         else
         {
            FarmStatsManager.count("collections","complete_toaster_clickbody",this.m_collection.name,"","",Global.worldManager.currentWorldType);
         }
         close();
         UI.displayPopup(new CollectionsWindow(this.m_collection));
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var item:FarmItem = null;
         var bundleData:Object = null;
         var messageType:String = null;
         var emailData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_collectibleCode);
            bundleData = {
               "rarity":this.m_rarity,
               "collectable":item.friendlyName,
               "reward_link":this.m_shareLink,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_shareLink,
                  "src":item.icon
               }]
            };
            messageType = "FoundRare";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
            emailData = {
               "item_name":item.friendlyName,
               "reward_link":this.m_shareLink
            };
            TransactionManager.addTransaction(new TGiftGive(messageType,emailData,[]));
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_shareLink]));
         }
      }
      
      protected function onCollectionComplete(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayPopup(new CollectionsWindow());
         }
      }
   }
}

