package Display
{
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Transactions.TCollectionTradeIn;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Collections extends SlotDialog
   {
      
      protected static const NUM_COLLECTABLES:int = 6;
      
      private static const NUM_SLOTS:int = 3;
      
      protected var m_howDoesThisWorkPopup:GenericPopup = null;
      
      public function Collections()
      {
         m_dialogAsset = "assets/dialogs/FV_Collections.swf";
         super();
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         ZLocUtils.setText(m_window,"giftsTitle_tf","Dialogs","Collections");
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         var howDoesThisWorkBtn:GenericButton = new GenericButton(m_window.whatisthis_mc,this.onClickHowDoesThisWork);
         howDoesThisWorkBtn.m_overlay.name = "HowDoesThisWorkBtn";
         howDoesThisWorkBtn.text = ZLocUtils.t("Dialogs","HowDoesThisWork");
         m_tiles.push(m_window.collectionPanel1,m_window.collectionPanel2,m_window.collectionPanel3);
         this.removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < NUM_SLOTS && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         if(!Global.player.getSeenFlag("FirstTimeOpenCollectionsDialog"))
         {
            Global.player.setSeenFlag("FirstTimeOpenCollectionsDialog");
            this.onClickHowDoesThisWork();
         }
      }
      
      private function pushNewData() : void
      {
         var objectXML:XML = null;
         var collection:Collection = null;
         m_data = [];
         m_tileSet = 0;
         var objects:XMLList = Global.farmGameSettingsManager.getCollections();
         for(var objectIdx:int = 0; objectIdx < objects.length(); objectIdx++)
         {
            objectXML = objects[objectIdx];
            if(objectXML.attribute("type").toString() == Collection.TYPE_PERMANENT)
            {
               collection = new Collection(objectXML);
               m_data.push(collection);
            }
         }
         fixArrows();
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         this.closeHowDoesThisWorkPopup();
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         event.stopPropagation();
         close();
      }
      
      override protected function removeTiles(hideTiles:Boolean = true) : void
      {
         var index:int = 0;
         this.closeHowDoesThisWorkPopup();
         for(var compIdx:int = 0; compIdx < this.getNumSlots(); compIdx++)
         {
            if(hideTiles)
            {
               for(index = 1; index <= NUM_COLLECTABLES; index++)
               {
                  Utilities.removeAllChildren(m_tiles[compIdx]["icon" + index]);
               }
               m_tiles[compIdx].visible = false;
               postRemoveTiles(compIdx);
            }
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var collection:Collection = null;
         var collectables:XMLList = null;
         var collectablesIdx:int = 0;
         var gb:GenericButton = null;
         var code:String = null;
         var item:FarmItem = null;
         var collectableIndex:String = null;
         var tileSet:int = 0;
         var url:String = null;
         var icon:Loader = null;
         var toolTip:ToolTip = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            collection = m_data[index + compId] as Collection;
            mc.visible = true;
            mc.collectionsTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].friendlyName);
            if(collection.getCurrentUniqueCollectablesCount() == collection.getTotalCollectablesCount())
            {
               mc.collectionsTitleGreen_tf.visible = true;
               mc.collectionsTitle_tf.visible = false;
               mc.collectionsTitleGreen_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].friendlyName);
               mc.starsComplete_mc.visible = true;
               mc.completeBackground_mc.visible = true;
               mc.incompleteBackground_mc.visible = false;
               mc.tradeIn_bt.visible = true;
               gb = new GenericButton(mc.tradeIn_bt,this.onTradeInClick,"",collection.code);
               gb.disabled = false;
               mc.genericButton = gb;
            }
            else
            {
               mc.collectionsTitleGreen_tf.visible = false;
               mc.collectionsTitle_tf.visible = true;
               mc.collectionsTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].friendlyName);
               mc.starsComplete_mc.visible = false;
               mc.completeBackground_mc.visible = false;
               mc.incompleteBackground_mc.visible = true;
               mc.tradeIn_bt.visible = false;
               if(mc.genericButton)
               {
                  mc.genericButton.disabled = true;
               }
            }
            collectables = collection.getCollectablesXMLList();
            for(collectablesIdx = 0; collectablesIdx < collectables.length(); collectablesIdx++)
            {
               code = collectables[collectablesIdx].@code;
               item = Global.farmGameSettingsManager.getFarmItemByCode(code);
               collectableIndex = int(collectablesIdx + 1).toString();
               mc["itemTitle" + collectableIndex + "_tf"].text = ZLocUtils.tk_pk_asTitle(item.friendlyName);
               if(null != Global.player.collectionCounters[code] && Global.player.collectionCounters[code] > 0)
               {
                  mc["giftAmount" + collectableIndex + "_tf"].text = Global.player.collectionCounters[code].toString();
                  mc["icon" + collectableIndex].alpha = 1;
               }
               else
               {
                  mc["giftAmount" + collectableIndex + "_tf"].text = "0";
                  mc["icon" + collectableIndex].alpha = 0.25;
               }
               if(collectables[collectablesIdx].@rarity == "uncommon")
               {
                  mc["rare" + collectableIndex + "_tf"].text = ZLocUtils.t("Collections","Uncommon");
               }
               else if(collectables[collectablesIdx].@rarity == "rare")
               {
                  mc["rare" + collectableIndex + "_tf"].text = ZLocUtils.t("Collections","Rare");
               }
               else
               {
                  mc["rare" + collectableIndex + "_tf"].text = ZLocUtils.t("Collections","Common");
               }
               tileSet = m_tileSet;
               url = item.icon;
               icon = LoadingManager.load(url,function(event:Event):void
               {
                  var dispObj:* = undefined;
                  var icon:* = event.target;
                  if(Boolean(icon) && Boolean(icon.content) && m_tileSet == tileSet)
                  {
                     Utilities.removeAllChildren(mc[icon.loader.name]);
                     dispObj = icon.content;
                     dispObj.width = 55;
                     dispObj.height = 55;
                     mc[icon.loader.name].addChild(dispObj);
                  }
               });
               icon.name = "icon" + collectableIndex;
               if(!mc["tooltip" + collectableIndex])
               {
                  toolTip = new ToolTip();
                  toolTip.attachToolTip(mc[icon.name]);
                  mc["tooltip" + collectableIndex] = toolTip;
               }
               mc["tooltip" + collectableIndex].toolTip = ZLocUtils.t("Collections",collectables[collectablesIdx].@source + "_toolTip");
            }
         }
      }
      
      protected function onTradeInClick(event:MouseEvent) : void
      {
         this.closeHowDoesThisWorkPopup();
         var collectionCode:String = event.target.name;
         var collection:Collection = Global.farmGameSettingsManager.getCollectionByCode(collectionCode);
         collection.tradeIn();
         TransactionManager.addTransaction(new TCollectionTradeIn(collectionCode),true);
         close();
      }
      
      protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         if(this.m_howDoesThisWorkPopup == null)
         {
            msg = ZLocUtils.t("Dialogs","CollectionsHowDoesThisWork");
            this.m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG);
            this.m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(this.m_howDoesThisWorkPopup,false,"howDoesThisWorkPopup",true);
         }
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      protected function closeHowDoesThisWorkPopup() : void
      {
         if(null != this.m_howDoesThisWorkPopup)
         {
            this.m_howDoesThisWorkPopup.close();
            this.m_howDoesThisWorkPopup = null;
         }
      }
   }
}

