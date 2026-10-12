package Display
{
   import Classes.AnimalStorageBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CustomFreeGiftSelectionWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class StorageWithdrawal extends SlotDialog
   {
      
      protected var m_toolTips:Array = new Array();
      
      private const NUM_SLOTS:int = 6;
      
      protected var m_building:StorageBuilding;
      
      protected var m_usedTypes:Object = null;
      
      protected var m_buttons:Array = new Array();
      
      protected var m_dialogType:String;
      
      protected var m_howDoesThisWorkPopup:GenericPopup = null;
      
      public function StorageWithdrawal(storage:StorageBuilding)
      {
         this.m_building = storage;
         if(null == m_dialogAsset && null == this.m_dialogType)
         {
            m_dialogAsset = "assets/dialogs/FV_DairyFarm.swf";
            this.m_dialogType = "dairyfarm";
         }
         super();
      }
      
      public function get storageBuildingId() : Number
      {
         return this.m_building.getId();
      }
      
      override protected function onLoadComplete() : void
      {
         var gb:GenericButton = null;
         super.onLoadComplete();
         if(m_window.hasOwnProperty("gifts_mc") && Boolean(m_window.gifts_mc["close_bt"]))
         {
            m_window.gifts_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
            if(Boolean(m_window.gifts_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.gifts_mc.hasOwnProperty("arrowRt_bt")))
            {
               m_window.gifts_mc.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
               m_window.gifts_mc.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
            }
         }
         ZLocUtils.setTextAsTitle(m_window,"gifts_mc.giftsTitle_tf",this.m_building.getItemFriendlyName());
         this.setupCapacityBox();
         if(Boolean(m_window.gifts_mc.hasOwnProperty("howDoes_mc")) && Boolean(m_window.gifts_mc.howDoes_mc))
         {
            gb = new GenericButton(m_window.gifts_mc.howDoes_mc,this.onClickHowDoesThisWork);
            gb.m_overlay.name = "HowDoesThisWorkBtn";
            gb.text = ZLocUtils.t("Dialogs","HowDoesThisWork");
         }
         this.setupTiles();
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < this.getNumSlots() && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
      }
      
      protected function setupCapacityBox() : void
      {
         if(m_window.hasOwnProperty("capacity_tf") && m_window.hasOwnProperty("current_tf"))
         {
            ZLocUtils.setText(m_window,"capacity_tf","Dialogs","Capacity",{"quantity":this.m_building.capacity});
            ZLocUtils.setText(m_window,"current_tf","Dialogs","Current",{"quantity":this.m_building.count});
         }
         else if(Boolean(m_window.gifts_mc.hasOwnProperty("capacity_tf")) && Boolean(m_window.gifts_mc.hasOwnProperty("current_tf")))
         {
            ZLocUtils.setText(m_window,"gifts_mc.capacity_tf","Dialogs","Capacity",{"quantity":this.m_building.capacity});
            ZLocUtils.setText(m_window,"gifts_mc.current_tf","Dialogs","Current",{"quantity":this.m_building.count});
         }
      }
      
      protected function setupTiles() : void
      {
         var tileName:String = null;
         for(var tileIdx:int = 0; tileIdx < this.getNumSlots(); tileIdx++)
         {
            tileName = "giftPanel" + int(tileIdx + 1).toString();
            if(m_window.gifts_mc.hasOwnProperty(tileName))
            {
               m_tiles.push(m_window.gifts_mc.getChildByName(tileName));
            }
         }
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function fixArrows() : void
      {
         if(Boolean(m_window.gifts_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.gifts_mc.hasOwnProperty("arrowRt_bt")))
         {
            m_window.gifts_mc.arrowLt_bt.visible = m_tileSet > 0 ? true : false;
            m_window.gifts_mc.arrowRt_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
         }
      }
      
      protected function pushNewData() : void
      {
         var objectIdx:int = 0;
         var object:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         var giftItemCode:String = null;
         var giftItemName:String = null;
         var giftXML:XML = null;
         m_data = [];
         m_tileSet = 0;
         this.m_usedTypes = new Object();
         var objects:Array = this.m_building.getContents();
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = new Object();
               giftItem = objects[objectIdx].item;
               giftNum = Number(objects[objectIdx].num);
               giftItemCode = objects[objectIdx].code != null ? objects[objectIdx].code : giftItem.code;
               giftItemName = objects[objectIdx].name != null ? objects[objectIdx].name : giftItem.name;
               if(this.m_usedTypes[giftItemCode] == null)
               {
                  this.m_usedTypes[giftItemCode] = giftNum;
                  object.name = giftItemName;
                  object.code = giftItemCode;
                  object.type = giftItem.type;
                  object.localizedName = giftItem.friendlyName;
                  object.cost = giftItem.cost;
                  object.sellPrice = giftItem.sellDisplayPrice;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(giftItem.hasPropertyInDataSource("coinYield"))
                     {
                        object.coinYield = giftItem.getNumberFromDataSource("coinYield");
                     }
                     if(this.m_building.getItem().hasPropertyInDataSource("growTime"))
                     {
                        object.harvestTime = this.m_building.getItem().getNumberFromDataSource("growTime");
                     }
                  }
                  else
                  {
                     giftXML = giftItem.xml;
                     if(giftXML.coinYield)
                     {
                        object.coinYield = giftXML.coinYield;
                     }
                     if(this.m_building.getItem().xml.growTime)
                     {
                        object.harvestTime = this.m_building.getItem().xml.growTime;
                     }
                  }
                  if(giftItem.sizeX)
                  {
                     object.sizeX = giftItem.sizeX;
                  }
                  if(giftItem.sizeY)
                  {
                     object.sizeX = giftItem.sizeY;
                  }
                  m_data.push(object);
               }
               else
               {
                  this.m_usedTypes[objects[objectIdx].itemCode] += 1;
               }
            }
         }
         this.fixArrows();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            m_tiles[compId].visible = true;
            m_tiles[compId].itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].localizedName);
            if(m_data[index + compId].sellPrice.toString() != "")
            {
               m_tiles[compId].yield_tf.visible = true;
               m_tiles[compId].yield_tf.htmlText = ZLocUtils.t("Dialogs","Yield",{
                  "coinQuantity":m_data[index + compId].sellPrice,
                  "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",m_data[index + compId].sellPrice)
               });
            }
            else if(m_tiles[compId].yield_tf)
            {
               m_tiles[compId].yield_tf.visible = false;
            }
            if(m_data[index + compId].harvestTime.toString() != "")
            {
               m_tiles[compId].growth_tf.visible = true;
               m_tiles[compId].growth_tf.text = ZLocUtils.t("Dialogs","GrowthDays",{
                  "quantity":m_data[index + compId].harvestTime,
                  "Day_word":ZLocUtils.tk("Dialogs","Day_word","",m_data[index + compId].harvestTime)
               });
            }
            else if(m_tiles[compId].growth_tf)
            {
               m_tiles[compId].growth_tf.visible = false;
            }
            m_tiles[compId].giftAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":this.m_usedTypes[m_data[index + compId].code]});
            this.m_buttons[compId] = new GenericButton(m_tiles[compId].use_bt,this.onUse);
            this.m_buttons[compId].m_overlay.name = m_data[index + compId].name;
            this.m_buttons[compId].text = ZLocUtils.t("Dialogs","Remove");
            this.addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon);
         }
      }
      
      protected function addIcon(itemName:String, imageName:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50) : void
      {
         var icon:Loader = null;
         var url:String = Global.farmGameSettingsManager.getImageByName(itemName,imageName);
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               if(tile)
               {
                  Utilities.removeAllChildren(movieClip);
               }
               dispObj = icon.content;
               dispObj.width = width;
               dispObj.height = height;
               movieClip.addChild(dispObj);
            }
         });
      }
      
      protected function onClickHowDoesThisWork(event:Event = null) : void
      {
         var msg:String = null;
         if(this.m_howDoesThisWorkPopup == null)
         {
            msg = ZLocUtils.t("Dialogs","ChickenHowDoesThisWork");
            this.m_howDoesThisWorkPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET_LRG);
            this.m_howDoesThisWorkPopup.setAcceptTextName("Okay");
            UI.displayPopup(this.m_howDoesThisWorkPopup,false,"howDoesThisWorkPopup",true);
         }
      }
      
      protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         this.m_howDoesThisWorkPopup = null;
      }
      
      protected function onUse(event:Event) : void
      {
         var itemName:String = event.target.name;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(this is AnimalStorageBuilding)
         {
            AnimalStorageBuilding(this.m_building).isBusy = true;
         }
         var extraData:Object = new Object();
         extraData.isGift = false;
         if(itemName != farmItem.name)
         {
            extraData.realItemName = itemName;
         }
         farmItem.onUse(this.storageBuildingId,extraData);
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         FarmStatsManager.count(this.m_dialogType,"click_use");
         this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         if(null != this.m_howDoesThisWorkPopup)
         {
            this.m_howDoesThisWorkPopup.close();
         }
         removeTiles(false);
         this.m_usedTypes = null;
         m_window.gifts_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         if(Boolean(m_window.gifts_mc.hasOwnProperty("arrowLt_bt")) && Boolean(m_window.gifts_mc.hasOwnProperty("arrowRt_bt")))
         {
            m_window.gifts_mc.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
            m_window.gifts_mc.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         }
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      protected function showGiftingOverlay(showSelectedGift:Boolean = false) : void
      {
         var buildingContents:Array = null;
         var partItem:PartItem = null;
         var gifts:Array = null;
         if(showSelectedGift)
         {
            gifts = new Array();
            buildingContents = this.m_building.getConstructionItems();
            for each(partItem in buildingContents)
            {
               if(partItem.item.giftable)
               {
                  gifts.push(partItem.item.name);
               }
            }
            UI.displayPopup(new CustomFreeGiftSelectionWindow(gifts));
         }
         else
         {
            FreeGiftSelectionWindow.popWindow();
         }
         close();
      }
   }
}

