package Display
{
   import Classes.HolidayPresent;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TOpenHolidayPresent;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HolidayTreeWithdrawal extends StorageWithdrawal
   {
      
      private const NUM_SLOTS:int = 6;
      
      public function HolidayTreeWithdrawal(storage:StorageBuilding)
      {
         m_dialogAsset = "assets/dialogs/FV_PottingShed.swf";
         m_dialogType = "holidayTree";
         super(storage);
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function pushNewData() : void
      {
         var goldStartDate:Number = NaN;
         var objectIdx:int = 0;
         var object:Object = null;
         var giftItem:FarmItem = null;
         var giftNum:Number = NaN;
         var presentXML:XML = null;
         m_data = [];
         m_tileSet = 0;
         m_usedTypes = new Object();
         var objects:Array = m_building.getContents();
         var goldenItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("present_gold");
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            goldStartDate = FarmGameUtil.synchronizedDateToNumber(goldenItem.getStringFromDataSource("openStart"));
         }
         else
         {
            goldStartDate = FarmGameUtil.synchronizedDateToNumber(goldenItem.xml.openStart);
         }
         if(GlobalEngine.serverTime > goldStartDate)
         {
            objects.splice(0,0,{
               "item":goldenItem,
               "num":1
            });
         }
         if(objects)
         {
            for(objectIdx = 0; objectIdx < objects.length; objectIdx++)
            {
               object = new Object();
               giftItem = objects[objectIdx].item;
               giftNum = Number(objects[objectIdx].num);
               if(m_usedTypes[giftItem.code] == null)
               {
                  m_usedTypes[giftItem.code] = giftNum;
                  object.name = giftItem.name;
                  object.code = giftItem.code;
                  object.localizedName = giftItem.friendlyName;
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(giftItem.hasPropertyInDataSource("openStart"))
                     {
                        object.openStart = giftItem.getStringFromDataSource("openStart");
                     }
                     if(giftItem.hasPropertyInDataSource("openEnd"))
                     {
                        object.openEnd = giftItem.getStringFromDataSource("openEnd");
                     }
                     if(giftItem.getBoolFromDataSource("golden"))
                     {
                        object.golden = true;
                     }
                  }
                  else
                  {
                     presentXML = giftItem.xml;
                     if(presentXML.openStart)
                     {
                        object.openStart = presentXML.openStart.toString();
                     }
                     if(presentXML.openEnd)
                     {
                        object.openEnd = presentXML.openEnd.toString();
                     }
                     if(Boolean(presentXML.@golden) && presentXML.@golden.toString() == "true")
                     {
                        object.golden = true;
                     }
                  }
                  m_data.push(object);
               }
               else
               {
                  m_usedTypes[objects[objectIdx].itemCode] += 1;
               }
            }
         }
         fixArrows();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var startDate:Number = NaN;
         var canUse:Boolean = false;
         var callback:Function = null;
         var buttonLoc:String = null;
         var endDate:Number = NaN;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            m_tiles[compId].visible = true;
            m_tiles[compId].itemTitle_tf.text = ZLocUtils.tk_pk_asTitle(m_data[index + compId].localizedName);
            if(m_data[index + compId].golden == true)
            {
               m_tiles[compId].whatisthis_bt = new GenericButton(m_tiles[compId].whatisthis_mc);
               m_tiles[compId].whatisthis_mc.visible = true;
            }
            else
            {
               m_tiles[compId].whatisthis_mc.visible = false;
            }
            startDate = 0;
            if(m_data[index + compId].openStart != "")
            {
               startDate = FarmGameUtil.synchronizedDateToNumber(m_data[index + compId].openStart);
            }
            if(m_data[index + compId].openStart != "" && startDate > GlobalEngine.serverTime)
            {
               m_tiles[compId].alive_tf.visible = true;
               m_tiles[compId].alive_tf.text = ZLocUtils.t("Dialogs","HolidayTreeOpenOn",{"date":m_data[index + compId].openStart});
            }
            else if(m_tiles[compId].alive_tf)
            {
               m_tiles[compId].alive_tf.visible = false;
            }
            if(m_data[index + compId].golden)
            {
               m_tiles[compId].giftAmount_tf.visible = false;
            }
            else
            {
               m_tiles[compId].giftAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":m_usedTypes[m_data[index + compId].code]});
            }
            m_tiles[compId].share_bt.visible = false;
            m_tiles[compId].use_bt.visible = false;
            canUse = true;
            if(m_data[index + compId].openStart != "" && m_data[index + compId].openEnd != "")
            {
               endDate = FarmGameUtil.synchronizedDateToNumber(m_data[index + compId].openEnd);
               if(startDate > GlobalEngine.serverTime || endDate < GlobalEngine.serverTime)
               {
                  canUse = false;
               }
            }
            if(m_data[index + compId].golden)
            {
               callback = this.onConfirmTrade;
               buttonLoc = "Trade";
            }
            else
            {
               callback = this.onUse;
               buttonLoc = "Open";
            }
            m_buttons[compId] = new GenericButton(m_tiles[compId].trade_bt,callback);
            if(canUse == true || m_data[index + compId].golden == true)
            {
               m_buttons[compId].m_overlay.name = m_data[index + compId].name;
               m_buttons[compId].text = ZLocUtils.t("Dialogs",buttonLoc);
               m_buttons[compId].disabled = false;
               m_buttons[compId].turnOn();
            }
            else
            {
               m_buttons[compId].disabled = true;
               m_buttons[compId].turnOff();
            }
            addIcon(m_data[index + compId].name,"icon",m_tiles[compId],m_tiles[compId].icon);
         }
      }
      
      private function removePresent(itemCode:String) : void
      {
         ++Global.player.numOpenedPresents;
         m_building.removeContents(itemCode);
         m_window.current_tf.text = ZLocUtils.t("Dialogs","Current",{"quantity":m_building.count});
         --m_usedTypes[itemCode];
      }
      
      private function clearEmptyPresents() : void
      {
         for(var dataX:int = 0; dataX < m_data.length; dataX++)
         {
            if(m_usedTypes[m_data[dataX].code] == 0)
            {
               m_data.splice(dataX,1);
            }
         }
      }
      
      override protected function onUse(event:Event) : void
      {
         var item:FarmItem = null;
         var maxGiftLimit:Number = NaN;
         var present:HolidayPresent = null;
         var itemName:String = event.target.name;
         item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var itemCode:String = item.code;
         if(Global.player.hasGiftBoxCapacity())
         {
            this.removePresent(itemCode);
            this.clearEmptyPresents();
            refreshLayout(true);
            present = new HolidayPresent(itemName);
            TransactionManager.addTransaction(new TOpenHolidayPresent(present,m_building,false),true);
            FarmStatsManager.count("holidayTree","open_present");
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",itemName + "_TooManyGifts"));
         }
      }
      
      private function tradePresents(numPresents:int) : Object
      {
         var code:String = null;
         var result:Object = new Object();
         var numFound:int = 0;
         for(var presentX:int = 1; presentX < m_data.length; presentX++)
         {
            code = m_data[presentX].code;
            while(m_usedTypes[code] > 0 && numFound < numPresents)
            {
               this.removePresent(code);
               numFound++;
               if(result.hasOwnProperty(code) == false)
               {
                  result[code] = 1;
               }
               else
               {
                  ++result[code];
               }
            }
         }
         return result;
      }
      
      private function onTrade(event:GenericPopupEvent) : void
      {
         var itemName:String = null;
         var cash:int = 0;
         var presents:int = 0;
         var farmItem:FarmItem = null;
         var goldPresentXML:XML = null;
         var codesRemoved:Object = null;
         var present:HolidayPresent = null;
         var result:Boolean = event.button == GenericPopup.YES;
         if(result == true)
         {
            itemName = "present_gold";
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cash = int(farmItem.getPropertyFromCashItemSaleSource("cash"));
               presents = int(farmItem.getPropertyFromCashItemSaleSource("presents"));
            }
            else
            {
               goldPresentXML = farmItem.cashXML ? farmItem.cashXML : (farmItem.xml ? farmItem.xml : farmItem.saleXML);
               cash = int(goldPresentXML.cash);
               presents = int(goldPresentXML.presents);
            }
            if(Global.player.canBuyCash(cash))
            {
               if(m_building.count >= presents)
               {
                  if(Global.player.hasGiftBoxCapacity())
                  {
                     codesRemoved = this.tradePresents(presents);
                     this.clearEmptyPresents();
                     refreshLayout(true);
                     Global.player.cash -= cash;
                     present = new HolidayPresent(itemName);
                     TransactionManager.addTransaction(new TOpenHolidayPresent(present,m_building,true,codesRemoved),true);
                     FarmStatsManager.count("holidayTree","trade_present");
                  }
                  else
                  {
                     UI.displayMessage(ZLocUtils.t("Dialogs",itemName + "_TooManyGifts"),GenericPopup.TYPE_OK,null,"",true);
                  }
               }
               else
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs",itemName + "_NeedPresents"),GenericPopup.TYPE_OK,null,"",true);
               }
            }
         }
      }
      
      private function onConfirmTrade(event:Event) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","present_gold_ConfirmTrade"),GenericPopup.TYPE_TRADECANCEL,this.onTrade,"",true);
      }
   }
}

