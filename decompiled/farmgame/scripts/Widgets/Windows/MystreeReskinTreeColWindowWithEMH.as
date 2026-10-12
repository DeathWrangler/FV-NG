package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.MystreeReskinManagerWithEMH;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class MystreeReskinTreeColWindowWithEMH extends FarmWindow
   {
      
      protected static const ASSET_PATH:String = "assets/dialogs/FV_CupidsStable_Collection.swf";
      
      private static const TREE_PREFIX:String = "treecount_tf";
      
      private var m_featureName:String = null;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_isCongratsPopUp:Boolean = false;
      
      private var m_itemName:FarmItem = null;
      
      private var m_treeCollection:MovieClip;
      
      private var m_buyButtonArray:Array = new Array();
      
      private var m_animalArray:Array = new Array();
      
      private var m_treecollection_share_Stage:FarmAnimatedButton;
      
      public function MystreeReskinTreeColWindowWithEMH(featureName:String = null, isCongratsPopUp:Boolean = false)
      {
         this.m_featureName = featureName;
         var dialogPath:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getCollectionDialogURL();
         dialogPath = dialogPath == "" ? ASSET_PATH : dialogPath;
         this.m_isCongratsPopUp = isCongratsPopUp;
         if(dialogPath != "")
         {
            super(dialogPath);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_title")),true);
         }
         if(m_window.hasOwnProperty("collection_mc"))
         {
            this.m_treeCollection = m_window.collection_mc;
         }
         if(this.m_treeCollection.hasOwnProperty("close_bt"))
         {
            m_closeButton = addWidget(new FarmButton(m_window.collection_mc.close_bt,this.onClose)) as FarmButton;
         }
         if(this.m_treeCollection.hasOwnProperty("subtitle1_tf"))
         {
            this.m_treecollection_subtitle_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
         }
         if(this.m_treeCollection.hasOwnProperty("share_bt"))
         {
            this.m_treecollection_share_Stage = addWidget(new FarmAnimatedButton(m_window.collection_mc.share_bt,this.onStageshare),true) as FarmAnimatedButton;
            this.m_treecollection_share_Stage.visible = false;
         }
         this.m_treeCollection.visible = true;
         this.recursivelyPlay(m_window);
         this.refreshTreeCollection();
      }
      
      public function onStageshare(e:Event) : void
      {
         var shareStageURL:String = null;
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         var message:String = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_title");
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("sharePhotoResponseHandler",this.sharePhotoResponseHandler);
            shareStageURL = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_shareStage" + MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getDifficultyLevel());
            ExternalUtil.instance.call("FarmNS.Request2Manager.shareFarmstamaticPhoto",shareStageURL,message);
         }
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
            ToasterManager.getInstance().add(new FeedPostCompleteToasterWindow("Shared The Adventurers Inc.",null,new Point(0,0)));
         }
         close();
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
         var count:int = 0;
         var mystreeItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getCollectionData();
         var mystrees:Array = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getMystreeData();
         var windowName:String = MystreeReskinManagerWithEMH.getInstance(this.m_featureName).getWindowName();
         var treeCount:int = 0;
         if(this.m_treeCollection)
         {
            for(i = 0; i < mystrees.length; i++)
            {
               count = int(collectionData[mystrees[i]]);
               if(count == 0)
               {
                  isAllCollected = false;
               }
               else
               {
                  treeCount++;
               }
               if(count > 999)
               {
                  (this.m_treeCollection["counter_mc_" + i][TREE_PREFIX] as TextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_maxShowtreeCount");
               }
               else
               {
                  (this.m_treeCollection["counter_mc_" + i][TREE_PREFIX] as TextField).text = "x" + count.toString();
                  mystreeItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(mystreeItem)
                  {
                     this.m_animalArray[i] = this.m_treeCollection["animal_mc_" + i] as MovieClip;
                     if(count == 0 && MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
                     {
                        this.m_animalArray[i].transform.colorTransform = new ColorTransform(0.1,0.1,0.1,0.7,0,0,0,0);
                     }
                     this.m_buyButtonArray[i] = new FarmAnimatedCashButton(this.m_treeCollection["counter_mc_" + i].buyCash_bt,"Buy",mystreeItem.cash.toString(),this.onBuyClick(mystreeItem));
                     if(MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isStageComplete())
                     {
                        this.m_buyButtonArray[i].visible = true;
                        this.m_treecollection_share_Stage.visible = true;
                     }
                     else if(!MystreeReskinManagerWithEMH.getInstance(this.m_featureName).isFeatureInActivePeriod())
                     {
                        this.m_buyButtonArray[i].visible = true;
                     }
                     else
                     {
                        this.m_buyButtonArray[i].visible = false;
                     }
                     if(this.m_isCongratsPopUp)
                     {
                        this.m_buyButtonArray[i].visible = false;
                        this.m_treecollection_share_Stage.visible = true;
                     }
                  }
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_incomplete",{
                  "treeCount":treeCount,
                  "totalCount":mystrees.length
               });
            }
            else
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_complete");
            }
         }
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
            canBuy = Global.player.canBuyCash(this.m_itemName.cash,false);
            if(canBuy == true)
            {
               Global.player.cash -= this.m_itemName.cash;
               Global.player.addGift(this.m_itemName.name,"0",1);
               MystreeReskinManagerWithEMH.getInstance(this.m_featureName).setClaimedTreeFeatureOption(this.m_itemName.code);
               TransactionManager.addTransaction(new TGenericTransaction("MystreeReskinService","buyMystreeItem",null,[this.m_featureName,this.m_itemName.name]),true);
               title = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_title");
               message = ZLocUtils.t("Dialogs","PromoFarm_ModelFarmNPC_PurchaseConfirm_body",{"item":ZLocUtils.tk_pk(this.m_itemName.friendlyName)});
               UI.showMessage(message,UI.BUTTON_LAYOUT_OK,title,this.m_itemName.iconRelativeUrl);
               close();
            }
         }
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override protected function onClose(e:Event) : void
      {
         UI.displayPopup(new MystreeReskinWindowWithEMH(this.m_featureName));
         close();
      }
   }
}

