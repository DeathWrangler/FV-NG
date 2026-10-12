package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.MystreeReskinManagerWithoutEMH;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   
   public class MystreeReskinTreeColWindow extends FarmWindow
   {
      
      protected static const ASSET_PATH:String = "assets/dialogs/FV_CupidsStable_Collection.swf";
      
      private static const TREE_PREFIX:String = "treecount_";
      
      private static const TOOLTIP_PRIFIX:String = "tooltip_";
      
      private static const ANIMAL_PREFIX:String = "animal_mc_";
      
      private static const COUNTER_PREFIX:String = "counter_mc_";
      
      private static const COLLECTIONS:Array = ["Spooky Movies","Skeleton Show","Walk of Magic"];
      
      private static const COLLECTION1:int = 0;
      
      private static const COLLECTION2:int = 1;
      
      private static const COLLECTION3:int = 2;
      
      private var m_featureName:String = null;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_collection_no:int = -1;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_treecollection_subtitle1_tf:ZwTextField;
      
      private var m_treecollection_subtitle2_tf:ZwTextField;
      
      private var m_treecollection_subtitle3_tf:ZwTextField;
      
      private var m_GrantBonusFlag:Boolean = false;
      
      private var m_treeCollection:MovieClip;
      
      private var m_treeCollection1:MovieClip;
      
      private var m_treeCollection2:MovieClip;
      
      private var m_treeCollection3:MovieClip;
      
      private var m_treeCollection4:MovieClip;
      
      private var m_tree1_bt:FarmAnimatedTextButton;
      
      private var m_tree2_bt:FarmAnimatedTextButton;
      
      private var m_tree3_bt:FarmAnimatedTextButton;
      
      public var START_STAGE:Array = [0,6,12,18];
      
      private var m_treecollection1_title_tf:ZwTextField;
      
      private var m_treecollection2_title_tf:ZwTextField;
      
      private var m_treecollection3_title_tf:ZwTextField;
      
      public function MystreeReskinTreeColWindow(featureName:String = null)
      {
         this.m_featureName = featureName;
         var dialogPath:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionDialogURL();
         dialogPath = dialogPath == "" ? ASSET_PATH : dialogPath;
         if(dialogPath != "")
         {
            super(dialogPath);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         var isCollectionCompleted:int = -1;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_title")),true);
         }
         if(m_window.hasOwnProperty("subtitle1_tf"))
         {
            this.m_treecollection_subtitle1_tf = addWidget(new ZwTextField(m_window.subtitle1_tf),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty("collection_mc"))
         {
            this.m_treeCollection = m_window.collection_mc;
            if(this.m_treeCollection.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(this.m_treeCollection.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
            }
            this.m_treeCollection.visible = true;
            this.recursivelyPlay(m_window);
            this.refreshTreeCollection();
         }
         if(m_window.hasOwnProperty("collection1_mc"))
         {
            this.m_treeCollection1 = m_window.collection1_mc;
            if(this.m_treeCollection1.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection1_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(this.m_treeCollection1.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle1_tf = addWidget(new ZwTextField(m_window.collection1_mc.subtitle1_tf),true) as ZwTextField;
            }
            if(this.m_treeCollection1.hasOwnProperty("title_tf"))
            {
               this.m_treecollection1_title_tf = new ZwTextField(m_window.collection1_mc.title_tf,COLLECTIONS[0]) as ZwTextField;
               this.m_treecollection1_title_tf.visible = true;
            }
            this.m_treeCollection1.visible = true;
            this.recursivelyPlay(m_window);
            if(this.refreshTreeSpecificCollection(COLLECTION1) && !this.manager.hasRewardbeenGranted(COLLECTION1))
            {
               isCollectionCompleted = COLLECTION1;
            }
            if(this.m_treeCollection1.hasOwnProperty("view_bt"))
            {
               this.m_tree1_bt = new FarmAnimatedTextButton(this.m_treeCollection1.view_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_view_bt"),this.f1(COLLECTION1));
            }
         }
         if(m_window.hasOwnProperty("collection2_mc"))
         {
            this.m_treeCollection2 = m_window.collection2_mc;
            if(this.m_treeCollection2.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection2_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(this.m_treeCollection2.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle2_tf = addWidget(new ZwTextField(m_window.collection2_mc.subtitle1_tf),true) as ZwTextField;
            }
            if(this.m_treeCollection2.hasOwnProperty("title_tf"))
            {
               this.m_treecollection2_title_tf = new ZwTextField(m_window.collection2_mc.title_tf,COLLECTIONS[1]) as ZwTextField;
               this.m_treecollection2_title_tf.visible = true;
            }
            this.m_treeCollection2.visible = true;
            this.recursivelyPlay(m_window);
            if(this.refreshTreeSpecificCollection(COLLECTION2) && !this.manager.hasRewardbeenGranted(COLLECTION2))
            {
               isCollectionCompleted = COLLECTION2;
            }
            if(this.m_treeCollection2.hasOwnProperty("view_bt"))
            {
               this.m_tree2_bt = new FarmAnimatedTextButton(this.m_treeCollection2.view_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_view_bt"),this.f1(COLLECTION2));
            }
         }
         if(m_window.hasOwnProperty("collection3_mc"))
         {
            this.m_treeCollection3 = m_window.collection3_mc;
            if(this.m_treeCollection3.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection3_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(this.m_treeCollection3.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle3_tf = addWidget(new ZwTextField(m_window.collection3_mc.subtitle1_tf),true) as ZwTextField;
            }
            if(this.m_treeCollection3.hasOwnProperty("title_tf"))
            {
               this.m_treecollection3_title_tf = new ZwTextField(m_window.collection3_mc.title_tf,COLLECTIONS[2]) as ZwTextField;
               this.m_treecollection3_title_tf.visible = true;
            }
            this.m_treeCollection3.visible = true;
            this.recursivelyPlay(m_window);
            if(this.refreshTreeSpecificCollection(COLLECTION3) && !this.manager.hasRewardbeenGranted(COLLECTION3))
            {
               isCollectionCompleted = COLLECTION3;
            }
            if(this.m_treeCollection3.hasOwnProperty("view_bt"))
            {
               this.m_tree3_bt = new FarmAnimatedTextButton(this.m_treeCollection3.view_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_view_bt"),this.f1(COLLECTION3));
            }
         }
         if(MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).isFeatureInRedeemPeriod() && this.m_featureName == MystreeReskinManagerWithoutEMH.FEATURE_NAME)
         {
            if(m_window.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle1_tf.text = "Buy more unlocked spooky animals before 12/08/2020";
            }
         }
         if(isCollectionCompleted != -1)
         {
            this.m_collection_no = isCollectionCompleted;
            this.GrantReward(isCollectionCompleted);
         }
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         var isCongrats:Boolean = true;
         if(this.m_GrantBonusFlag && MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionNumberDialogURL(this.m_collection_no) != "")
         {
            UI.displayPopup(new MystreeFurryAndFabulousCollectionWindow(this.m_featureName,this.m_collection_no,isCongrats),false);
         }
      }
      
      private function get manager() : MystreeReskinManagerWithoutEMH
      {
         return MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName);
      }
      
      private function GrantReward(collection_no:int) : void
      {
         var isRewardGranted:Boolean = this.manager.hasRewardbeenGranted(collection_no);
         if(!isRewardGranted && this.manager.isFeatureInActivePeriod())
         {
            if(Boolean(m_window) && MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionNumberDialogURL(collection_no) != "")
            {
               MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).GrantCollectionCompletionBonus(collection_no);
               this.m_GrantBonusFlag = true;
            }
         }
      }
      
      private function f1(collection_no:int) : Function
      {
         return function(e:Event):void
         {
            if(m_window)
            {
               m_closeButton.visible = false;
               if(m_treeCollection)
               {
                  m_treeCollection.visible = true;
                  refreshTreeCollection();
               }
               else if(MystreeReskinManagerWithoutEMH.getInstance(m_featureName).getCollectionNumberDialogURL(collection_no) != "")
               {
                  UI.displayPopup(new MystreeFurryAndFabulousCollectionWindow(m_featureName,collection_no));
                  close();
               }
            }
         };
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
         var itemNameToolTip:ZwWidget = null;
         var mystreeItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = this.manager.getCollectionData();
         var mystrees:Array = this.manager.getMystreeData();
         var windowName:String = this.manager.getWindowName();
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
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_maxShowtreeCount");
               }
               else
               {
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = count.toString();
               }
               if(this.m_treeCollection[TOOLTIP_PRIFIX + i])
               {
                  itemNameToolTip = new ZwWidget(this.m_treeCollection[TOOLTIP_PRIFIX + i]);
                  mystreeItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(Boolean(itemNameToolTip) && Boolean(mystreeItem))
                  {
                     itemNameToolTip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(mystreeItem.friendlyName)));
                  }
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_incomplete",{"treeCount":treeCount});
            }
            else
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_complete");
            }
         }
      }
      
      private function refreshTreeSpecificCollection(collection_no:int = -1) : Boolean
      {
         var i:int = 0;
         var count:int = 0;
         var ItemNameToolTip:ZwWidget = null;
         var mystreeItem:FarmItem = null;
         var bonusNameTooltip:ZwWidget = null;
         var bonusItem:FarmItem = null;
         var isAllCollected:Boolean = true;
         var collectionData:Object = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getCollectionData();
         var mystrees:Array = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getMystreeData();
         var windowName:String = MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).getWindowName();
         var bonusCode:Array = this.manager.getBonusCodes();
         var treeCount:int = 0;
         var start:int = 0;
         var end:int = 0;
         start = int(this.START_STAGE[collection_no]);
         end = int(this.START_STAGE[collection_no + 1]);
         this.m_treeCollection4 = m_window["collection" + (collection_no + 1).toString() + "_mc"];
         if(Boolean(this.m_treeCollection4) && collection_no != -1)
         {
            for(i = start; i < end; i++)
            {
               count = int(collectionData[mystrees[i]]);
               if(count == 0)
               {
                  isAllCollected = false;
                  this.m_treeCollection4[ANIMAL_PREFIX + i % 6].transform.colorTransform = new ColorTransform(0.1,0.1,0.1,0.7,0,0,0,0);
               }
               else
               {
                  treeCount++;
               }
               if(count > 999)
               {
                  (this.m_treeCollection4[COUNTER_PREFIX + i % 6]["treecount_tf"] as TextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_maxShowtreeCount");
               }
               else
               {
                  (this.m_treeCollection4[COUNTER_PREFIX + i % 6]["treecount_tf"] as TextField).text = "x" + count.toString();
               }
               if(Boolean(this.m_treeCollection4[ANIMAL_PREFIX + i % 6]) && count != 0)
               {
                  ItemNameToolTip = new ZwWidget(this.m_treeCollection4[ANIMAL_PREFIX + i % 6]);
                  mystreeItem = Global.farmGameSettingsManager.getFarmItemByCode(mystrees[i]);
                  if(Boolean(ItemNameToolTip) && Boolean(mystreeItem))
                  {
                     ItemNameToolTip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(mystreeItem.friendlyName)));
                  }
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_incomplete",{"treeCount":treeCount});
            }
            else
            {
               this.m_treecollection_subtitle1_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,windowName + "_subtitle1_complete",{"treeCount":treeCount});
            }
            if(this.m_treeCollection4[ANIMAL_PREFIX + "6"])
            {
               bonusNameTooltip = new ZwWidget(this.m_treeCollection4[ANIMAL_PREFIX + "6"]);
               bonusItem = Global.farmGameSettingsManager.getFarmItemByCode(bonusCode[collection_no]);
               if(Boolean(bonusNameTooltip) && Boolean(bonusItem))
               {
                  bonusNameTooltip.attachTooltip(new FarmTextTooltip(ZLocUtils.tk_pk_asTitle(bonusItem.friendlyName)));
               }
            }
            this.m_treeCollection4.checkmark_mc.visible = isAllCollected;
         }
         return isAllCollected;
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
      
      override protected function onClose(e:Event) : void
      {
         if(!MystreeReskinManagerWithoutEMH.getInstance(this.m_featureName).isFeatureInRedeemPeriod())
         {
            UI.displayPopup(new MystreeReskinWindow(this.m_featureName));
         }
         close();
      }
   }
}

