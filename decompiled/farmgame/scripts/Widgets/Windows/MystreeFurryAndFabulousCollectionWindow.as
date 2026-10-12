package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.MystreeReskinManagerWithEMH;
   import Managers.MystreeReskinManagerWithoutEMH;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class MystreeFurryAndFabulousCollectionWindow extends FarmWindow
   {
      
      protected static const ASSET_PATH:String = "assets/dialogs/FV_CupidsStable_Collection.swf";
      
      private static const TREE_PREFIX:String = "counter_mc_";
      
      private static const TOOLTIP_PREFIX:String = "animal_mc_";
      
      private var m_featureName:String = null;
      
      private var m_collection_no:int = 0;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_treecollection_subtitle1_tf:ZwTextField;
      
      private var m_treeCollection:MovieClip;
      
      private var m_buyButtonArray:Array = new Array();
      
      private var m_animalArray:Array = new Array();
      
      private var m_iscongrats:Boolean = false;
      
      public var START_STAGE:Array = [0,6,12,18];
      
      private var m_treecollection_share_Stage:FarmAnimatedTextButton;
      
      private var m_itemName:FarmItem = null;
      
      public function MystreeFurryAndFabulousCollectionWindow(featureName:String = null, collection_no:int = 0, isCongrats:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_collection_no = collection_no;
         this.m_iscongrats = isCongrats;
         var dialogPath:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionNumberDialogURL(collection_no);
         dialogPath = dialogPath == "" ? ASSET_PATH : dialogPath;
         if(dialogPath != "")
         {
            super(dialogPath);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var title:String = null;
         super.postLoadComplete();
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         if(m_window.hasOwnProperty("title_tf"))
         {
            title = windowName + "_collection" + this.m_collection_no.toString() + "_title";
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,title)),true);
         }
         if(m_window.hasOwnProperty("subtitle1_tf"))
         {
            this.m_treecollection_subtitle1_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty("collection_mc"))
         {
            this.m_treeCollection = m_window.collection_mc;
            if(this.m_treeCollection.hasOwnProperty("close_bt"))
            {
               m_closeButton = addWidget(new FarmButton(this.m_treeCollection.close_bt,this.onClose)) as FarmButton;
            }
            if(this.m_treeCollection.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(this.m_treeCollection.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
            }
            if(this.m_treeCollection.hasOwnProperty("share_bt"))
            {
               this.m_treecollection_share_Stage = addWidget(new FarmAnimatedTextButton(m_window.collection_mc.share_bt,"Share My Stage!",this.onStageshare),true) as FarmAnimatedTextButton;
               this.m_treecollection_share_Stage.visible = false;
            }
            this.m_treeCollection.visible = true;
            this.recursivelyPlay(m_window);
            this.refreshTreeCollection();
         }
      }
      
      private function get manager() : MystreeReskinManagerWithoutEMH
      {
         return MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName);
      }
      
      private function recursivelyPlay(container:DisplayObjectContainer) : void
      {
         var displayContainer:DisplayObjectContainer = null;
         if(container is MovieClip)
         {
            MovieClip(container).play();
         }
         for(var childIdx:int = 0; childIdx < container.numChildren; childIdx++)
         {
            displayContainer = container.getChildAt(childIdx) as DisplayObjectContainer;
            if(Boolean(displayContainer) && displayContainer.numChildren > 1)
            {
               this.recursivelyPlay(displayContainer);
            }
         }
      }
      
      private function refreshTreeCollection() : void
      {
         var i:int = 0;
         var totalCount:int = 0;
         var counterNo:int = 0;
         var counterName:String = null;
         var animalName:String = null;
         var count:int = 0;
         var bonusCode:Array = null;
         var mystreeItem:FarmItem = null;
         var itemNameToolTip:ZwWidget = null;
         var mystreeAnimalItem:FarmItem = null;
         var bonusNameTooltip:ZwWidget = null;
         var bonusItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = this.manager.getCollectionData();
         var mystrees:Array = this.manager.getMystreeData();
         var windowName:String = this.manager.getWindowName();
         var bonusInfo:Dictionary = this.manager.getBonusItemsInfo();
         var treeCount:int = 0;
         var start:int = 0;
         var end:int = 0;
         start = int(this.START_STAGE[this.m_collection_no]);
         end = int(this.START_STAGE[this.m_collection_no + 1]);
         if(this.m_treeCollection)
         {
            for(i = start; i < end; i++)
            {
               counterNo = i % 6;
               counterName = TREE_PREFIX + counterNo.toString();
               animalName = TOOLTIP_PREFIX + counterNo.toString();
               count = int(collectionData[mystrees[i]]);
               bonusCode = this.manager.getBonusCodes();
               if(count == 0)
               {
                  isAllCollected = false;
                  this.m_treeCollection[animalName].transform.colorTransform = new ColorTransform(0.1,0.1,0.1,0.7,0,0,0,0);
                  this.m_treeCollection[counterName].buyCash_bt.visible = false;
               }
               else
               {
                  treeCount++;
               }
               if(count > 999)
               {
                  (this.m_treeCollection[counterName]["treecount_tf"] as TextField).text = "_maxShowtreeCount";
               }
               else
               {
                  (this.m_treeCollection[counterName]["treecount_tf"] as TextField).text = "x" + count.toString();
                  mystreeItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(mystreeItem)
                  {
                     this.m_animalArray[i] = this.m_treeCollection[counterName] as MovieClip;
                     if(count == 0 && this.manager.isFeatureInActivePeriod())
                     {
                        (this.m_treeCollection[counterName]["treecount_tf"] as TextField).visible = false;
                        this.m_animalArray[i].transform.colorTransform = new ColorTransform(0.1,0.1,0.1,0.7,0,0,0,0);
                     }
                     this.m_buyButtonArray[i] = new FarmAnimatedCashButton(this.m_treeCollection[counterName].buyCash_bt,"Buy",mystreeItem.cash.toString(),this.onBuyClick(mystreeItem));
                     if(this.manager.isFeatureInRedeemPeriod() && count > 0)
                     {
                        this.m_buyButtonArray[i].visible = true;
                     }
                     else
                     {
                        this.m_buyButtonArray[i].visible = false;
                     }
                  }
               }
               if(this.m_treeCollection[animalName])
               {
                  itemNameToolTip = new ZwWidget(this.m_treeCollection[animalName]);
                  mystreeAnimalItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(Boolean(itemNameToolTip) && Boolean(mystreeAnimalItem))
                  {
                     itemNameToolTip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(mystreeAnimalItem.friendlyName)));
                  }
               }
            }
            totalCount = 6;
            this.m_treeCollection[TREE_PREFIX + "6"].visible = false;
            if(this.m_treeCollection[TOOLTIP_PREFIX + "6"])
            {
               bonusNameTooltip = new ZwWidget(this.m_treeCollection[TOOLTIP_PREFIX + "6"]);
               bonusItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode[this.m_collection_no]);
               if(Boolean(bonusNameTooltip) && Boolean(bonusItem))
               {
                  bonusNameTooltip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(bonusItem.friendlyName)));
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_incomplete");
               this.m_treeCollection.checkmark_mc.visible = false;
            }
            else
            {
               this.m_treeCollection.checkmark_mc.visible = true;
               this.m_treecollection_share_Stage.visible = true;
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_complete");
            }
            if(this.manager.isFeatureInRedeemPeriod())
            {
               this.m_treecollection_subtitle_tf.text = "Buy more unlocked spooky animals before 12/08/2020";
            }
         }
      }
      
      private function clickAwesome(e:Event = null) : void
      {
         UI.displayPopup(new MystreeReskinWindow(this.m_featureName));
         close();
      }
      
      override protected function release() : void
      {
         this.m_awesome_bt = null;
         super.release();
      }
      
      private function onBuyClick(item:FarmItem) : Function
      {
         return function(event:Event):void
         {
            var unlockcost:* = item.cash;
            m_itemName = item;
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_featureName + "_BuyPlot_friction2",{
               "cashQuantity":unlockcost,
               "item":ZLocUtils.tk_pk(m_itemName.friendlyName)
            }),GenericPopup.TYPE_ACCEPTCANCEL,generateBuyCallback,"",true);
         };
      }
      
      private function generateBuyCallback(e:GenericPopupEvent) : void
      {
         var canBuy:Boolean = false;
         var title:String = null;
         var message:String = null;
         if(Boolean(e) && e.button == GenericPopup.YES)
         {
            canBuy = Global.player.canBuyCash(this.m_itemName.cash,true);
            if(canBuy == true)
            {
               Global.player.cash -= this.m_itemName.cash;
               Global.player.addGift(this.m_itemName.name,"0",1);
               this.manager.setClaimedTreeFeatureOption(this.m_itemName.code);
               TransactionManager.addTransaction(new TGenericTransaction("MystreeReskinService","buyMystreeItem",null,[this.m_featureName,this.m_itemName.name]),true);
               title = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_title");
               message = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_body",{"item":ZLocUtils.tk_pk(this.m_itemName.friendlyName)});
               UI.showMessage(message,UI.BUTTON_LAYOUT_OK,title,this.m_itemName.iconRelativeUrl);
               close();
            }
         }
      }
      
      public function onStageshare(e:Event) : void
      {
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         var bundleId:String = windowName + "ShareStage";
         var imageIcon:String = Global.getAssetURL("assets/dialogs/Mystrees_SpookyRamp2020/ShareBragFeed.png");
         var collection:String = ["Spooky Movies","Skeleton Show","Walk of Magic"][this.m_collection_no];
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":imageIcon
            }],
            "actor":Global.player.name,
            "first_name":Global.player.firstName,
            "item":collection
         };
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,[],false,null);
         close();
      }
      
      public function sharePhotoResponseHandler(response:Object) : void
      {
         ToasterManager.getInstance().togglePause(false);
         if(response == null || response.hasOwnProperty("error"))
         {
            StatsManager.count("camera","errors","share_failed");
            ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow("Save Failed",null,new Point(0,0)));
         }
         else
         {
            ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow("Shared The Farmville Carnival Parade",null,new Point(0,0)));
         }
         close();
      }
      
      public function bragFeed(item:FarmItem, rewardType:String) : void
      {
         var rewardTypeText:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + rewardType);
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":item.icon
            }],
            "first_name":Global.player.firstName,
            "reward_name":"Special reward",
            "rarity":rewardTypeText,
            "item":item.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("FurryAndFabulous_Reward_Grant",bundleData,[],false,null);
      }
      
      override protected function onClose(e:Event) : void
      {
         if(!this.m_iscongrats)
         {
            UI.displayPopup(new MystreeReskinTreeColWindow(this.m_featureName));
         }
         close();
      }
   }
}

